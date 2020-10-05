# hotpocket_client_lib

HotPocket Dart Client Library

## Initialize HotPocket Client Library

In the main.dart file, you need to specify the HotPocket Nodes and protocol to be used (Json/Bson).
```
const List<String> hpNodes = ['ws://45.76.184.88:8080'];
HotPocketClient.init(hpNodes, protocol: Protocols.BSON);
```

Connect/disconnect HotPocket nodes.
```
await HotPocketClient.connect(); //Connect
await HotPocketClient.disconnect(); //Disconnect
```

## Read Request

Sending Read Request
```
HotPocketClient.sendContractReadRequest(List<int> binaryData);
```

Listening for Read Response
```
 HotPocketClient.listenForContractReadResponse(
                      callback: (dynamic content) {
   // Write your code...                
 });
```

## Contract Input/Output

Sending Contract Input
```
HotPocketClient.sendContractInput(List<int> binaryData);
```

Listening for Contract Output
```
 HotPocketClient.listenForContractOutput(
                      callback: (dynamic content) {
     // Write your code...              
 });
```

