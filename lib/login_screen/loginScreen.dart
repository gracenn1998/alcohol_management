import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({this.onSignedIn});
  final VoidCallback onSignedIn;
  State<StatefulWidget> createState() => _LoginPageState();
}

class EmailFieldValidator{
  static String validate(String value)
  {
    if (value.isEmpty)
      return 'Không thể bỏ trống email.';
    //kiem tra email @___.potato.com
    if (!(value.contains('@driver.potato.com')
        || value.contains('@manager.potato.com')
        || value.contains('@admin.potato.com')))
      return 'Email phải là email của pồ tây tô com pa ni';
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

  final bgColor = const Color(0xff0A2463);
  final labelColor = const Color(0xff00BC94);
  final labelStyle = TextStyle(color: Color(0xff00BC94));
  final hStyle = TextStyle(color: Colors.white.withOpacity(0.4));
  final inputStyle = TextStyle(color: Colors.white);
//  final _emailController = TextEditingController();
//  final _pwdController = TextEditingController();
//
  String _email, _password;

//  void dispose() {
//    _emailController.dispose();
//    _pwdController.dispose();
//    super.dispose();
//  }

  bool validateAndSave(){
    final form = _formKey.currentState;
    if (form.validate())
     {
       form.save();
       return true;
     }
    return false;
  }

  void _showDiaLog(){
    showDialog(context: context,
    builder: (BuildContext context){
      return AlertDialog(
        content: new Text("Sai tài khoảng hoặc mật khẩu. Nhập lại đi :("),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("Close"))
        ],
      );
    }
    );
  }

  Future<void> validateAndSubmit() async{
    if (validateAndSave()) {
      //ketnoiFirebase kt tk
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;
        final String _userID = await auth.signInWithEmailAndPassword(_email,_password);
        print('Da dang nhap duoc: ${_userID}');
        widget.onSignedIn();
      }
      catch (e) {
        print('Sai tài khoản hoặc mật khẩu ');
        _showDiaLog();
        print('$e');
      }
    }

  }

  Widget build(BuildContext context)
  {
    Widget emailField = TextFormField(
     // controller: _emailController,
        key: Key('email'),
      validator: EmailFieldValidator.validate,
      obscureText: false,
      onSaved: (String value){ _email = value; _email.toString().trim();},
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
      key: Key('password'),
     // controller: _pwdController,
      validator: PwdFieldValidator.validate,
      onSaved: (String value){ _password = value;},
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
          key: Key('signIn'),
          onPressed: validateAndSubmit,
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
