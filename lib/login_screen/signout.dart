import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';

class SignoutPage extends StatelessWidget {
    const SignoutPage({this.onSignedOut});
    final VoidCallback onSignedOut;

    Future<void> _signOut(BuildContext context) async{
      try{
        final BaseAuth auth = AuthProvider.of(context).auth;
        await auth.signOut();
        onSignedOut();
      } catch (e){
        print(e);
      }
    }

    Widget build(BuildContext context)
    {
      return Scaffold(
        body: Container(
          child: FlatButton(
              onPressed: () => _signOut(context),
              child: Center(child: Text(
                'ĐĂNG XUẤT',
                textAlign: TextAlign.center,
              ))
              ),
          )
        );
    }

}