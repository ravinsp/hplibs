using System;
using System.Threading.Tasks;
using HotPocket.Client;

namespace ExampleClient
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var server = new Uri("ws://45.32.247.212:8080");
            using var key = HotPocketKeyGenerator.Generate();
            using var hpc = new HotPocketClient(server, key);

            if (!await hpc.ConnectAsync())
            {
                Console.WriteLine("Hot Pocket connection failed.");
                return;
            }
            Console.WriteLine("Hot Pocket connected.");

            await hpc.CloseAsync();
            Console.WriteLine("Hot Pocket connection closed.");
        }
    }
}
