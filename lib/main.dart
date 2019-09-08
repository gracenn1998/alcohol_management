import 'package:flutter/material.dart';
import 'package:alcohol_management/menu/menu.dart';
import 'package:alcohol_management/menu/menu_driver.dart';
import 'package:alcohol_management/menu/menu_manager.dart';
import './login_screen/loginScreen.dart';
import 'login_screen/auth.dart';
import 'root_page.dart';
import 'login_screen/auth_provider.dart';
import 'edit_screens/editTripScreen.dart';
import 'add_screens/addDriverScreen.dart';
import 'add_screens/addTripScreen.dart';
import 'menu/menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {    return
      AuthProvider(
        auth: Auth(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Welcome to Flutter',
              home: MyBottomMenu(),
//            home: EditTrip(tID: 'HT0002',),
//            home: AddTrip(),
//            home: RootPage(),
            theme: ThemeData(
              primaryColor: Color(0xff0a2463),
              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Roboto',
            )
        ),
      );
  }
}