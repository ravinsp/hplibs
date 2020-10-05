import 'package:flutter/material.dart';

class AppTheme {
//default theme
  static get theme {
    var primaryColor = Colors.blue;
    var primarySwatch = Colors.lightBlue;
    var secondaryColor = Colors.blueGrey;
    var backgroundColor = Colors.white;

    return ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or simply save your changes to "hot reload" in a Flutter IDE).
      // Notice that the counter didn't reset back to zero; the application
      // is not restarted.
      primarySwatch: primarySwatch,
      primaryColor: primaryColor,
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: primaryColor),
        headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline3: TextStyle(fontSize: 16.0, color: primaryColor),
        headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: secondaryColor),
        bodyText1: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, color: secondaryColor),
        bodyText2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: secondaryColor),
        button: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      disabledColor: secondaryColor,
      hintColor: Colors.orange,
      colorScheme: ColorScheme(
        primary: primaryColor,
        background: backgroundColor,
        secondary: secondaryColor,
        primaryVariant: Colors.black,
        error: Colors.red,
        brightness: Brightness.light,
        onBackground: backgroundColor,
        onError: Colors.red,
        onPrimary: Colors.green,
        onSecondary: secondaryColor,
        onSurface: backgroundColor,
        secondaryVariant: secondaryColor,
        surface: Colors.blueGrey[50]
      ),      
    );
  }
}
