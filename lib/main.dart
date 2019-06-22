import 'package:flutter/material.dart';
import './edit_screens/editDriverScreen.dart';
import './show_info_screens/showDriverInfoScreen.dart';
import './add_screens/addDriverScreen.dart';

import 'package:alcohol_management/menu/menu.dart';
import 'package:alcohol_management/menu/menu_driver.dart';
import 'package:alcohol_management/menu/menu_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//Comment this to test push/pull request
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: DriverMenu(),
//        home: LoginPage(),
      theme: ThemeData(
        primaryColor: Color(0xff0a2463),
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      )
    );
  }
}