import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showDriverInfoScreen.dart';

//class EditDriverInfo extends StatefulWidget {
//  const EditDriverInfo({Key key}) : super(key: key);
//
//  @override
//  State<StatefulWidget> createState() {
//    return _EditDriverInfoState();
//  }
//}

//class _EditDriverInfoState extends State<EditDriverInfo> {
//  String name = "Trần Văn A";
//
//  Widget build(BuildContext context) {
//
//  return Scaffold(
//      appBar: AppBar(
//        title: ListTile(
//          leading: IconButton(
//            icon: Icon(Icons.arrow_back_ios),
//            color: Color(0xff06E2B3),
//            onPressed: () {
//              //backkkk
//            },
//          ),
//          title: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center),
//          trailing: IconButton(
//            icon: Icon(Icons.check),
//            color: Color(0xff06E2B3),
//            onPressed: () {
//              //backkkk
//            },
//          ),
//        ),
//      ),
//      body: editAllInfo(driver),
//      resizeToAvoidBottomPadding: false,
//  );
//  }
//}


Widget editAllInfo(driver) {
  return Column(
    children: <Widget>[
      editBasicInfo(driver['name']),

      Expanded(
        child: Container(
          child: editDetails(driver['dID'], driver['idCard'],
              driver['address'], driver['email'],
              driver['gender'], driver['dob']),
//          margin: EdgeInsets.only(bottom: 15.0),

        )
      ),

//      Expanded(
//        flex: 3,
//        child: BlankPanel(),
//      ),


    ],
  );
}

Widget editBasicInfo(name) {
  return Container(
      height: 120.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 10.0),
              child: CircleAvatar(
                radius: 50.0,
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
                        initialValue: name,
                        style: driverNameStyle(),
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

Widget editDetails(id, idCard, address, email, gender, dob) {
  final df = new DateFormat('dd/MM/yyyy');
  var formatted_dob = df.format(dob.toDate());

  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      height: 395.0,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            showDetailItem('ID', id, 1),
//            editDetailInfo('Tuổi', '40', 0 ),
            editDetailItem('CMND', idCard, 0 ),
            editDetailItem('Địa chỉ', address, 1 ),
            showDetailItem('Email', email, 0 ),
            editDetailItem('Giới tính', gender=='M'?'Nam':'Nữ', 1 ),
            editDetailItem('Ngày sinh', formatted_dob, 0 ),
          ],
        )
      )
  );

}

Widget editDetailItem(title, data, line) {
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
          padding: EdgeInsets.only(left: 15.0, right: 15.0),

          decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
          child: TextFormField(
              initialValue: data.toString(),
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
