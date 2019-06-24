import 'package:flutter/material.dart';

const appBarTxTStyle =
  TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white);


TextStyle driverStatusDataStyle(status) {

  return TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color:  status == 0 ? Color(0xff00bc94) : //normal
            status == 1 ? Color(0xffef3964) : Color(0xff8391b3), //alarming - not working
  );

}

TextStyle driverStatusTitleStyle(status) {

  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xff8391b3),
  );
}

TextStyle driverNameStyle() {
  return TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}

TextStyle driverInfoStyle() {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
}

TextStyle journeyStatusStyle(status) {
  return TextStyle(
    color: status == 0 ? Color(0xff00bc94) :
           status == 1 ? Color(0xffef3964) : Color(0xfff9aa33),
    fontWeight: FontWeight.w400,
    fontFamily: "Roboto",
    fontStyle:  FontStyle.normal,
    fontSize: 15.0
  );
}

BoxDecoration oddLineDetails() {
  return BoxDecoration(
    border: Border(
        left: BorderSide(
          color: Color(0xffDCDEE0),
          width: 1.0,
        )

    ),
    color: Color(0xffF3F4F6),
  );
}

BoxDecoration evenLineDetails() {
  return BoxDecoration(
      border: Border(
          left: BorderSide(
            color: Color(0xffDCDEE0),
            width: 1.0,
          )

      ),

  );
}