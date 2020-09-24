using System;
using System.Text;
using System.Threading.Tasks;
using HotPocket.Client;

namespace ExampleClient
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var server = new Uri("ws://127.0.0.1:8081");
            using var key = HotPocketKeyGenerator.Generate();
            using var hpc = new HotPocketClient(server, key);

            if (!await hpc.ConnectAsync())
            {
                Console.WriteLine("Hot Pocket connection failed.");
                return;
            }
            Console.WriteLine("Hot Pocket connected.");

            Console.WriteLine("Read request...");
            var bytes = await hpc.SendReadRequest(Encoding.UTF8.GetBytes("read request hello"));
            Console.WriteLine(Encoding.UTF8.GetString(bytes));

            Console.WriteLine("Contract input...");
            var inputStatus = await hpc.SendContractInputAsync(Encoding.UTF8.GetBytes("input hello"));
            if (inputStatus.Accepted)
            {
                var outBytes = await hpc.ReceiveContractOutputAsync();
                Console.WriteLine(Encoding.UTF8.GetString(outBytes));
            }

            await hpc.CloseAsync();
            Console.WriteLine("Hot Pocket connection closed.");
        }
    }
}
