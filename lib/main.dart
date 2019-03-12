import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'widget/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyano',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: SplashScreen(
          seconds: 3,
          navigateAfterSeconds: HomeWidget(),
          title: Text(
            'Cyano',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          image: Image.asset('graphics/logo_white.png'),
          backgroundColor: Colors.cyan,
          styleTextUnderTheLoader: TextStyle(color: Colors.white),
          photoSize: 100.0,
          onClick: () => print("Flutter Egypt"),
          loaderColor: Colors.white),
    );
  }
}
