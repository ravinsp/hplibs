import 'package:flutter/material.dart';

import 'models/constants.dart';
import 'screens/homepage.dart';

class Routes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'HotPocket Client App',
      //initial route
      initialRoute: RoutePaths.HomePage,
      routes: {
        RoutePaths.HomePage: (context) => HomePage()
      }
    );
  }
}
