import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotpocket_client_lib/hotpocket_client_lib.dart';

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(title: 'HotPocket Client App', home: TestClient());
  }
}

class TestClient extends StatefulWidget {
  @override
  _TestClientState createState() => _TestClientState();
}

class _TestClientState extends State<TestClient> {
  final userInput = TextEditingController();
  final logData = TextEditingController();
  bool isConnected = false;

  @override
  void dispose() {
    userInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('HotPocket Client App'),
        ),
        body: new Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: userInput,
            ),
          ),
          new RaisedButton(
              onPressed: () async {
                isConnected = await HotPocketClient.connect();

                logData.text += "[INF] Hotpocket Connected.\n";
              },
              child: new Text('Connect HP')),
          new RaisedButton(
              onPressed: () async {
                if (isConnected) {
                  HotPocketClient.listenForContractReadResponse(
                      callback: (dynamic content) {
                    var response = utf8.decode(content);

                    logData.text +=
                        "[INF] Contract read response>> " + response + "\n";
                  });

                  logData.text +=
                      "[INF] Sending read request to echo contract...\n";

                  HotPocketClient.sendContractReadRequest(
                      utf8.encode(userInput.text));
                } else {
                  logData.text +=
                      "[ERR] Please connect to HotPocket to proceed further.\n";
                }
              },
              child: new Text('Read Request')),
          new RaisedButton(
              onPressed: () async {
                if (isConnected) {
                  HotPocketClient.listenForContractOutput(
                      callback: (dynamic content) {
                    var response = utf8.decode(content);

                    logData.text +=
                        "[INF] Contract output>> " + response + "\n";
                  });

                  logData.text +=
                      "[INF] Sending contract input to echo contract...\n" +
                          "[INF] (\"inputs\" are subjected to multi-node consensus so it will have some delay)\n";

                  HotPocketClient.sendContractInput(
                      utf8.encode(userInput.text));
                } else {
                  logData.text +=
                      "[ERR] Please connect to HotPocket to proceed further.\n";
                }
              },
              child: new Text('Contract I/O')),
          new RaisedButton(
              onPressed: () async {
                if (isConnected) {
                  await HotPocketClient.disconnect();
                  isConnected = false;
                  logData.text += "[INF] Hotpocket disconnected.\n";
                } else {
                  logData.text +=
                      "[ERR] Please connect to HotPocket to proceed further.";
                }
              },
              child: new Text('Disconnect HP')),
          SingleChildScrollView(
              child: new TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: logData,
          ))
        ]),
        resizeToAvoidBottomInset: false);
  }
}
