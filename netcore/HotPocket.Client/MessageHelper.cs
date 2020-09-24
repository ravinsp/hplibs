using System;
using System.IO;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Bson;
using Newtonsoft.Json.Linq;
using NSec.Cryptography;
using static HotPocket.Client.Constants;

namespace HotPocket.Client
{
    internal class MessageHelper
    {
        private readonly Key _key;
        private readonly string _protocol;

        public MessageHelper(Key key, string protocol)
        {
            _key = key;
            _protocol = protocol;
        }

        public JObject CreateHandshakeResponse(string challenge)
        {
            // For handshake response encoding Hot Pocket always uses json.
            // Handshake response will specify the protocol to use for subsequent messages.

            var sigBytes = SignatureAlgorithm.Ed25519.Sign(_key, Encoding.UTF8.GetBytes(challenge));

            var obj = new JObject();
            obj["type"] = "handshake_response";
            obj["challenge"] = challenge;
            obj["sig"] = sigBytes.ToString();
            obj["pubkey"] = "ed" + ToHex(_key.Export(KeyBlobFormat.RawPublicKey));
            obj["protocol"] = _protocol;

            return obj;
        }

        public JObject CreateContractInput(byte[] input, string nonce, int maxLclSeqNo)
        {
            if (input.Length == 0)
                return null;

            var inputContainer = new JObject();
            if (_protocol == Protocols.JSON)
                inputContainer["input"] = ToHex(input);
            else
                inputContainer["input"] = input;

            inputContainer["nonce"] = nonce;
            inputContainer["max_lcl_seqno"] = maxLclSeqNo;

            var inputContainerBytes = Serialize(inputContainer);
            var sigBytes = SignatureAlgorithm.Ed25519.Sign(_key, inputContainerBytes);

            var signedInpContainer = new JObject();
            signedInpContainer["type"] = "contract_input";
            if (_protocol == Protocols.JSON)
                signedInpContainer["input_container"] = ToHex(inputContainerBytes);
            else
                signedInpContainer["input_container"] = inputContainerBytes;
            signedInpContainer["sig"] = sigBytes;
            return signedInpContainer;
        }

        public JObject CreateReadRequest(byte[] request)
        {
            if (request.Length == 0)
                return null;

            var obj = new JObject();
            obj["type"] = "contract_read_request";
            if (_protocol == Protocols.JSON)
                obj["input"] = ToHex(request);
            else
                obj["input"] = request;

            return obj;
        }

        public JObject CreateStatusRequest()
        {
            JObject obj = new JObject();
            obj["type"] = "stat";
            return obj;
        }

        public byte[] Serialize(object obj)
        {
            if (_protocol == Protocols.JSON)
            {
                return Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(obj));
            }
            else
            {
                using (MemoryStream ms = new MemoryStream())
                using (BsonDataWriter writer = new BsonDataWriter(ms))
                {
                    JsonSerializer serializer = new JsonSerializer();
                    serializer.Serialize(writer, obj);
                    return ms.ToArray();
                }
            }
        }

        public JObject Deserialize(byte[] msg)
        {
            if (_protocol == Protocols.JSON)
            {
                return JsonConvert.DeserializeObject<JObject>(Encoding.UTF8.GetString(msg));
            }
            else
            {
                using (MemoryStream ms = new MemoryStream(msg))
                using (BsonDataReader reader = new BsonDataReader(ms))
                {
                    JsonSerializer serializer = new JsonSerializer();
                    return serializer.Deserialize<JObject>(reader);
                }
            }
        }

        private static string ToHex(byte[] bytes)
        {
            StringBuilder hex = new StringBuilder(bytes.Length * 2);
            foreach (byte b in bytes)
                hex.AppendFormat("{0:x2}", bytes);
            return hex.ToString();
        }
    }
}