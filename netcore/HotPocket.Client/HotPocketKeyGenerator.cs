using System;
using NSec.Cryptography;

namespace HotPocket.Client
{
    public static class HotPocketKeyGenerator
    {
        public static Key Generate()
        {
            return Key.Create(SignatureAlgorithm.Ed25519);
        }

        public static Key Generate(string privateKeyHex)
        {
            var bytes = ToByteArray(privateKeyHex);
            return Key.Import(SignatureAlgorithm.Ed25519, new ReadOnlySpan<byte>(bytes), KeyBlobFormat.RawPrivateKey);
        }

        private static byte[] ToByteArray(String hexString)
        {
            byte[] retval = new byte[hexString.Length / 2];
            for (int i = 0; i < hexString.Length; i += 2)
                retval[i / 2] = Convert.ToByte(hexString.Substring(i, 2), 16);
            return retval;
        }
    }
}