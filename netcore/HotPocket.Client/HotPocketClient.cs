using System;
using System.IO;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NSec.Cryptography;
using static HotPocket.Client.Constants;

namespace HotPocket.Client
{
    public class HotPocketClient : IDisposable
    {
        private readonly Uri _server;
        private readonly Key _key;
        private ClientWebSocket _ws;
        private readonly MessageHelper _msgHelper;
        private bool _disposedValue;

        public HotPocketClient(Uri server, Key key)
        {
            _server = server;
            _key = key;
            _msgHelper = new MessageHelper(key, Protocols.BSON);
        }

        public async Task<bool> ConnectAsync()
        {
            _ws = new ClientWebSocket();
            await _ws.ConnectAsync(_server, CancellationToken.None);

            // We'll abort if Hot Pocket doesn't send anything within this duration.
            using (CancellationTokenSource cts = new CancellationTokenSource(1000))
            {
                try
                {
                    var recvBytes = await RecieveAsync(cts.Token);

                    // Handshake challenge is always in JSON format.
                    var msg = JsonConvert.DeserializeObject<JObject>(Encoding.UTF8.GetString(recvBytes));
                    if (msg["type"].ToObject<string>() == "handshake_challenge")
                    {
                        var challenge = msg["challenge"].ToObject<string>();
                        var response = JsonConvert.SerializeObject(_msgHelper.CreateHandshakeResponse(challenge));
                        var sendBytes = Encoding.UTF8.GetBytes(response);
                        await SendAsync(sendBytes);

                        // Wait for some time and see whether we are still connected.
                        // Hot Pocket will drop the connection if our challenge response is invalid.
                        await Task.Delay(100);
                        if (_ws.State == WebSocketState.Open)
                            return true; // Hot Pocket connection established.
                    }
                }
                catch (TaskCanceledException)
                {
                }
            }

            await CloseAsync();
            return false;
        }

        public async Task CloseAsync()
        {
            try
            {
                await _ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Normal Closure", CancellationToken.None);
            }
            catch (WebSocketException)
            {
            }
        }

        public async Task<ContractInputStatus> SendContractInputAsync(byte[] input, string nonce = null, int? maxLclOffset = null)
        {
            if (!maxLclOffset.HasValue)
                maxLclOffset = 10;

            if (string.IsNullOrEmpty(nonce))
                nonce = DateTime.UtcNow.Ticks.ToString();

            var stat = await GetStatusAsync();
            if (stat == null)
                return new ContractInputStatus(false, "ledger_status_error");

            int maxLclSeqNo = stat.LclSeqNo + maxLclOffset.Value;
            var inputMsg = _msgHelper.CreateContractInput(input, nonce, maxLclSeqNo);
            var msgBytes = _msgHelper.Serialize(inputMsg);
            await SendAsync(msgBytes);

            var inputStatus = await ReceiveMessageAsync("contract_input_status", 10000);
            if (inputStatus == null)
                return new ContractInputStatus(false, "timeout");

            var inputSig = inputMsg["sig"].ToObject<byte[]>();
            var recvSig = inputStatus["input_sig"].ToObject<byte[]>();
            if (!inputSig.SequenceEqual(recvSig))
                return new ContractInputStatus(false, "signature_mismatch");

            if (inputStatus["status"].ToObject<string>() != "accepted")
                return new ContractInputStatus(false, inputStatus["reason"].ToObject<string>());

            return new ContractInputStatus(true);
        }

        public async Task<byte[]> ReceiveContractOutputAsync()
        {
            var recvMsg = await ReceiveMessageAsync("contract_output", 10000);
            if (recvMsg == null)
                return null;
            else
                return recvMsg["content"].ToObject<byte[]>();
        }

        public async Task<byte[]> SendReadRequest(byte[] request)
        {
            var msgBytes = _msgHelper.Serialize(_msgHelper.CreateReadRequest(request));
            await SendAsync(msgBytes);
            var recvMsg = await ReceiveMessageAsync("contract_read_response", 3000);
            if (recvMsg == null)
                return null;
            else
                return recvMsg["content"].ToObject<byte[]>();
        }

        public async Task<LedgerStatus> GetStatusAsync()
        {
            var sendBytes = _msgHelper.Serialize(_msgHelper.CreateStatusRequest());
            await SendAsync(sendBytes);
            var recvMsg = await ReceiveMessageAsync("stat_response");
            if (recvMsg == null)
                return null;

            return new LedgerStatus
            {
                Lcl = recvMsg["lcl"].ToObject<string>(),
                LclSeqNo = recvMsg["lcl_seqno"].ToObject<int>()
            };
        }

        private async Task<JObject> ReceiveMessageAsync(string type, int timeoutms = 0)
        {
            using (CancellationTokenSource cts = (timeoutms == 0 ? new CancellationTokenSource() : new CancellationTokenSource(timeoutms)))
            {
                try
                {
                    var msgBytes = await RecieveAsync(cts.Token);
                    var msg = _msgHelper.Deserialize(msgBytes);
                    if (msg["type"].ToObject<string>() == type)
                        return msg;
                }
                catch (TaskCanceledException)
                {
                }
            }

            return null;
        }

        private async Task<byte[]> RecieveAsync(CancellationToken cancellationToken)
        {
            var buffer = new ArraySegment<byte>(new byte[2048]);
            WebSocketReceiveResult result;
            using (var ms = new MemoryStream())
            {
                do
                {
                    result = await _ws.ReceiveAsync(buffer, cancellationToken);
                    ms.Write(buffer.Array, buffer.Offset, result.Count);
                } while (!result.EndOfMessage);

                return ms.ToArray();
            }
        }

        private async Task SendAsync(byte[] bytes)
        {
            await _ws.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Binary, true, CancellationToken.None);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposedValue)
            {
                if (disposing)
                {
                    _ws.Dispose();
                }

                _disposedValue = true;
            }
        }

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}
