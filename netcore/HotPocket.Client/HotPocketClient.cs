using System;
using System.IO;
using System.Net;
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
        private readonly MessageHelper _messageHelper;
        private bool _disposedValue;

        public HotPocketClient(Uri server, Key key)
        {
            _server = server;
            _key = key;
            _messageHelper = new MessageHelper(key, Protocols.BSON);
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
                    var challengeMsg = JsonConvert.DeserializeObject<JObject>(Encoding.UTF8.GetString(recvBytes));
                    if (challengeMsg["type"].ToObject<string>() == "handshake_challenge")
                    {
                        var challenge = challengeMsg["challenge"].ToObject<string>();
                        var sendBytes = _messageHelper.SerializeObject(_messageHelper.CreateHandshakeResponse(challenge));
                        await _ws.SendAsync(new ArraySegment<byte>(sendBytes), WebSocketMessageType.Binary, true, CancellationToken.None);

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
