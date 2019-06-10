import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../show_info_screens/showDriverInfoScreen.dart';

class AddDriver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddDriver();
  }
}

class _AddDriver extends State<AddDriver> {

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xff06E2B3),
            onPressed: () {
              //backkkk
            },
          ),
          title: Text('Thêm tài xế', style: appBarTxTStyle, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.check),
            color: Color(0xff06E2B3),
            onPressed: () {
              //backkkk
            },
          ),
        ),
      ),
      body: showAllInfo(),
      resizeToAvoidBottomPadding: false,
    );
  }
}


Widget showAllInfo() {
  return Column(
    children: <Widget>[
      Expanded(
        flex: 6,
        child: fillBasicInfo(),
      ),
      Expanded(
          flex: 19,
          child: fillDetails()
      ),

      Expanded(
        flex: 3,
        child: BlankPanel(),
      ),


    ],
  );
}

Widget fillBasicInfo() {
  return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 15.0),
              child: CircleAvatar(
                radius: 55.0,
                backgroundImage: AssetImage('images/avatar.png'),
              )
          ),
          Container(
              padding: EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    width: 250.0,
                    child: TextFormField(
                      style: driverNameStyle(),
                      decoration: InputDecoration(
                        hintText: "Tên tài xế",
                      )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        Text("Trạng thái: ", style: driverStatusTitleStyle(0)),
                        Text("n/a", style: driverStatusDataStyle(0)),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text("Nồng độ cồn: ", style: driverStatusTitleStyle(0)),
                      Text("n/a", style: driverStatusDataStyle(0)),
                    ],
                  ),
                ],
              )
          )
        ],
      )
  );
}

Widget fillDetails() {
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              fillDetailInfo('Tuổi', 0),
              fillDetailInfo('CMND', 1),
              fillDetailInfo('Địa chỉ', 0),
              fillDetailInfo('Email', 1),
              fillDetailInfo('Giới tính', 0),
              fillDetailInfo('Ngày sinh', 1),

              showDetailInfo('', '', 0 ),
              showDetailInfo('', '', 0 ),
              showDetailInfo('', '', 0 ),
              showDetailInfo('', '', 0 ),



            ],
          )
      )
  );

}

Widget fillDetailInfo(title, line) {
  return Row(
    children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
            height: 55.0,
//          margin: const EdgeInsets.all(5.0),
            padding: EdgeInsets.only(left: 25.0),
            decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$title",
                style: driverInfoStyle(),
              ),
            )
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          height: 55.0,
//          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(5.0),

          decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
          child: TextFormField(
            style: driverInfoStyle(),
          ),


        ),
      ),
    ],

  );
}


Widget BlankPanel() {
  return Container(
    color: Colors.white,
    margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),

  );
}
