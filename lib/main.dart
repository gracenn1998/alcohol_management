import 'package:flutter/material.dart';
import 'package:alcohol_management/menu/menu.dart';
import 'package:alcohol_management/menu/menu_driver.dart';
import 'package:alcohol_management/menu/menu_manager.dart';
import './login_screen/loginScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//Comment this to test push/pull request
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: DriverMenu(),
//      home: MyBottomMenu(),
//      home: ManagerMenu(),
      theme: ThemeData(
        primaryColor: Color(0xff0a2463),
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      )
    );
  }
}