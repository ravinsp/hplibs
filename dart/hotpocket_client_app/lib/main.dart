import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotpocket_client_app/route.dart';
import 'package:hotpocket_client_lib/hotpocket_client_lib.dart';
import 'package:hotpocket_client_lib/models/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const List<String> hpNodes = ['ws://45.76.184.88:8080'];
  HotPocketClient.init(hpNodes, protocol: Protocols.BSON);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(HotPocketClientApp());
  });
}

class HotPocketClientApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Routes();
  }
}
