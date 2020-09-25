using System;
using System.Text;
using System.Threading.Tasks;
using HotPocket.Client;

namespace ExampleClient
{
    // Example program to demonstrate Hot Pocket .Net Core client library.

    class Program
    {
        static async Task Main(string[] args)
        {
            // Generate a new key pair.
            using var keyPair = HotPocketKeyGenerator.Generate();

            // Generate a new key pair using existing private key.
            // using var keyPair = HotPocketKeyGenerator.Generate("<custom private key>");

            var server = new Uri("ws://<server ip>:<server poirt>");

            using var hpc = new HotPocketClient(server, keyPair);

            Console.WriteLine("Connecting to Hot Pocket...");
            if (!await hpc.ConnectAsync())
            {
                Console.WriteLine("Hot Pocket connection failed.");
                return;
            }
            Console.WriteLine("Hot Pocket connected.");

            Console.WriteLine();
            Console.WriteLine("Sending read request to echo contract...");
            var responseBytes = await hpc.SendReadRequestAsync(Encoding.UTF8.GetBytes("Hello there!"));
            Console.WriteLine("Smart contract replied>> " + Encoding.UTF8.GetString(responseBytes));

            Console.WriteLine();
            Console.WriteLine("Sending contract input to echo contract...");
            Console.WriteLine("(\"inputs\" are subjected to multi-node consensus so it will have some delay)");
            var inputStatus = await hpc.SendContractInputAsync(Encoding.UTF8.GetBytes("How are you?"));
            if (inputStatus.Accepted)
            {
                // After HotPocket confirms the input has been accepted, we wait for the response output.
                var outBytes = await hpc.ReceiveContractOutputAsync();
                Console.WriteLine("Smart contract replied>> " + Encoding.UTF8.GetString(outBytes));
            }

            await hpc.CloseAsync();
            Console.WriteLine();
            Console.WriteLine("Hot Pocket connection closed.");
        }
    }
}
