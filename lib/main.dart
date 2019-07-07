import 'package:flutter/material.dart';
import './edit_screens/editDriverScreen.dart';
import './show_info_screens/showDriverInfoScreen.dart';
import './add_screens/addDriverScreen.dart';
import 'login_screen/auth.dart';
import 'root_page.dart';
import 'menu.dart';
import 'login_screen/auth_provider.dart';
import 'show-trip-details/showTripDetails.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//Comment this to test push/pull request
    return
      AuthProvider(
        auth: Auth(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Welcome to Flutter',
            //  home: MyBottomMenu(),
            home: ShowTripDetails(jID: 'HT0004'),
            theme: ThemeData(
              primaryColor: Color(0xff0a2463),
              fontFamily: 'Roboto',
            )
        ),
      );

  }
}