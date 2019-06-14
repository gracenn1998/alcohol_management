import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget{
  State<StatefulWidget> createState() => _LoginPageState();
}

class EmailFieldValidator{
  static String validate(String value)
  {
    if (value.isEmpty)
      return 'Không thể bỏ trống email.';
    return null;
  }
}

class PwdFieldValidator{
  static String validate(String value)
  {
    if (value.isEmpty)
      return 'Không thể bỏ trống mật khẩu.';
    return null;
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool autoValidate = false;

  final bgColor = const Color(0xff0A2463);
  final labelColor = const Color(0xff00BC94);
  final labelStyle = TextStyle(color: Color(0xff00BC94));
  final hStyle = TextStyle(color: Colors.white.withOpacity(0.4));
  final inputStyle = TextStyle(color: Colors.white);

  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();
  String _email, _password;

  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  bool validateAndSave(){
    final form = _formKey.currentState;
    if (form.validate())
     {
       form.save();
       return true;
     }
    return false;
  }

  void validateAndSubmit(){
    if (validateAndSave()) {
      //ketnoiFirebase kt tk
      try {
        Future<FirebaseUser> _user = FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        print('${_user}');

      }
      catch (e) {
        print('Error: $e');
      }
    }
  }

  Widget build(BuildContext context)
  {
    Widget emailField = TextFormField(
      controller: _emailController,
      validator: EmailFieldValidator.validate,
      obscureText: false,
      onSaved: (value){ _email = value;},
      style: inputStyle,
      decoration: InputDecoration(
        enabledBorder: new UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00BC94))
        ),
        focusedBorder: new UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00BC94))
        ),
        hintText: "Nhập E-Mail",
        hintStyle: hStyle,
        labelText: "E-Mail",
        labelStyle: labelStyle,
      )
    );

    Widget pwdField = TextFormField(
      controller: _pwdController,
      validator: PwdFieldValidator.validate,
      onSaved: (value){ _password = value;},
      obscureText: true,
      style: inputStyle,
      decoration: InputDecoration(
        enabledBorder: new UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00BC94))
        ),
        focusedBorder: new UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00BC94))
        ),
        hintText: "Nhập mật khẩu",
        hintStyle: hStyle,
        labelText: "Mật khẩu",
        labelStyle: labelStyle,
      ),
    );

    Widget loginButton = Material(
        borderRadius: BorderRadius.circular(5.0),
        color: labelColor,
        child: MaterialButton(

          onPressed: (){
            //XU LY DANG NHAP-----------------------
            validateAndSubmit();
            // XU LY DANG NHAP-----------------------
          },
          child: Text(
            "ĐĂNG NHẬP",
            textAlign: TextAlign.center,
            style: TextStyle(color: bgColor,
                fontSize: 20
            ),
          ),
        ),
    );

    return Scaffold(
      body: Container(
          color: bgColor,
            padding: const EdgeInsets.all(70),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    emailField,
                    SizedBox(height: 20),
                    pwdField,
                    SizedBox(height: 40),
                    loginButton
                  ],
                )
            )
        ),
    );
  }


}
