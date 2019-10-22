import 'package:flutter/material.dart';
import 'login_screen/loginScreen.dart';
import 'login_screen/auth.dart';
import 'login_screen/signout.dart';
import 'login_screen/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alcohol_management/menu/menu_driver.dart';
import 'package:alcohol_management/menu/menu_manager.dart';

enum AuthStatus {
//  notDetermined,
  notSignedIn,
  signedIn
}

class RootPage extends StatefulWidget {
//    AuthStatus _authStatus = AuthStatus.notDetermined;



    State<StatefulWidget> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  String userID = '';


  void didChangeDependencies(){
    super.didChangeDependencies();
//    final BaseAuth auth = AuthProvider.of(context).auth;
    FirebaseAuth.instance.currentUser().then((user) {

      _authStatus = user == null ? AuthStatus.notSignedIn: AuthStatus.signedIn;
      if(_authStatus == AuthStatus.signedIn) {
        setState(() {
          userID = user.email.substring(0, user.email.indexOf('@'));
        });
      }

    });
//    auth.currentUser().then((userID){
//
//      setState(() {
//        _authStatus = userID == null ? AuthStatus.notSignedIn: AuthStatus.signedIn;
//
//      });
//    });
  }


  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
      FirebaseAuth.instance.currentUser().then((user) {
        userID = user.email.substring(0, user.email.indexOf('@'));
      });
    });
  }


  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  Widget build(BuildContext context){
//    FirebaseAuth.instance.signOut();
//    _authStatus = AuthStatus.notSignedIn;
    switch (_authStatus){
//      case AuthStatus.notDetermined:
//        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
//        return SignoutPage(
//          onSignedOut: _signedOut,
//        );
        if(userID.substring(0, 2) == 'tx')
          return DriverMenu(
            dID: userID.toUpperCase(),
          );
        if(userID.substring(0, 2) == 'nv')
          return ManagerMenu();
    }

    return null;

  }

  Widget _buildWaitingScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Text(
          'Khong biet'
        )
      ),
    );
  }
}