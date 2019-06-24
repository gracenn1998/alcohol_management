import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final bgColor = const Color(0xff0A2463);
  final labelColor = const Color(0xff00BC94);
  TextStyle labelStyle = TextStyle(color: Color(0xff00BC94));
  TextStyle hStyle = TextStyle(color: Colors.white.withOpacity(0.4));
  TextStyle inputStyle = TextStyle(color: Colors.white);

  Widget build(BuildContext context)
  {
    Widget emailField = TextField(
      obscureText: false,
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

    Widget pwdField = TextField(
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
            //XU LY DANG NHAP
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                emailField,
                SizedBox(height: 20),
                pwdField,
                SizedBox(height: 40),
                SizedBox(child: loginButton, width: 300)
                //loginButton
              ],
            )
        ),
    );
  }


}