using NSec.Cryptography;

namespace HotPocket.Client
{
    public static class HotPocketKeyGenerator
    {
        public static Key Generate()
        {
            return Key.Create(SignatureAlgorithm.Ed25519);
        }
    }
}