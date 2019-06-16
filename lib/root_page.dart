import 'package:flutter/material.dart';
import 'login_screen/loginScreen.dart';
import 'login_screen/auth.dart';
import 'login_screen/signout.dart';
import 'login_screen/auth_provider.dart';

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn
}

class RootPage extends StatefulWidget {
    State<StatefulWidget> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notDetermined;

  void didChangeDependencies(){
    super.didChangeDependencies();
    final BaseAuth auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userID){
      setState(() {
        _authStatus = userID == null ? AuthStatus.notSignedIn: AuthStatus.signedIn;

      });
    });
  }


  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }


  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  Widget build(BuildContext context){
    switch (_authStatus){
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return SignoutPage(
          onSignedOut: _signedOut,
        );
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