// Example program to demonstrate Hot Pocket NodeJs client library.
// Usage: node example.js

const { exit } = require('process');
const { HotPocketKeyGenerator, HotPocketClient, HotPocketEvents } = require('../hp-client-lib');

async function main() {

    // Generate a new key pair.
    const keys = await HotPocketKeyGenerator.generate();

    // Generate a new key pair using existing private key.
    // const keys = HotPocketKeyGenerator.generate("<custom private key hex>");

    const server = 'ws://<server>:<port>';
    const hpc = new HotPocketClient(server, keys);

    // Establish HotPocket connection.
    if (!await hpc.connect()) {
        console.log('Connection failed.');
        exit();
    }
    console.log('HotPocket Connected.');

    // This will get fired if HP server disconnects unexpectedly.
    hpc.on(HotPocketEvents.disconnect, () => {
        console.log('Server disconnected');
        exit();
    })

    // This will get fired when contract sends an output.
    hpc.on(HotPocketEvents.contractOutput, (output) => {
        console.log();
        console.log("Contract output>> " + output);
    })

    // This will get fired when contract sends a read response.
    hpc.on(HotPocketEvents.contractReadResponse, (response) => {
        console.log();
        console.log("Contract read response>> " + response);
    })

    // On ctrl + c we should close HP connection gracefully.
    process.once('SIGINT', async function () {
        console.log('SIGINT received...');
        await hpc.close();
        console.log("Hot Pocket connection closed.")
    });

    console.log();
    console.log("Sending read request to echo contract...");
    hpc.sendContractReadRequest("Hello there");

    console.log();
    console.log("Sending contract input to echo contract...");
    console.log("(\"inputs\" are subjected to multi-node consensus so it will have some delay)");
    const submissionStatus = await hpc.sendContractInput("Hi, how are you?");
    if (submissionStatus != "ok")
        console.log("Input submission failed. reason: " + submissionStatus);
}

main();