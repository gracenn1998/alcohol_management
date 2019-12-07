import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alcohol_management/root_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';



class SettingScreen extends StatefulWidget {
  const SettingScreen({Key key}) : super(key: key);
  @override
  _SettingScreenState createState() => _SettingScreenState();
}


class _SettingScreenState extends State<SettingScreen> {

  _SettingScreenState();


  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:  Center(child: Text('Cài đặt', style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),
      body: Center(child: signoutButton(context),),
      resizeToAvoidBottomPadding: false,

    );
  }

  Widget signoutButton(context) {
    return Container(
      height: 55.0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),
      child: RaisedButton(
        color: Color(0xff0a2463),
        child: Text(
          "Đăng xuất",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        elevation: 6.0,
        onPressed: () {
          //action
          try{
//            final FirebaseAuth auth = AuthProvider.of(context).auth;
//            await auth.signOut();
//            onSignedOut();
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RootPage())
            );
          } catch (e){
            print(e);
          }
        },
      ),
    );
  }
}
