import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../edit_screens/editDriverScreen.dart';

class ShowDriverInfo extends StatefulWidget {
  final String dID;
  const ShowDriverInfo({Key key, @required this.dID}) : super(key: key);
  @override
  _ShowDriverInfoState createState() => _ShowDriverInfoState(dID);
}


class _ShowDriverInfoState extends State<ShowDriverInfo> {
  String dID;
  _ShowDriverInfoState(this.dID);

  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if(_selectedIndex == -1) {
      return Center(
          child: Text(
            'List Tai Xe',
            style: tempStyle,
          ),
      );
    }
    if(_selectedIndex == 1) {
      return EditDriverInfo(
        dID: dID,
      );
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xff06E2B3),
            onPressed: () {
              //backkkk
              setState(() {
                _selectedIndex--;
              });
            },
          ),
          title:  Center(child: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,)),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: Icon(Icons.edit),
                color: Color(0xff06E2B3),
                onPressed: () {
                  //editttt
                setState(() {
                  _selectedIndex = 1;
                });
//                  Navigator.push(context, MaterialPageRoute(builder: (context) {
//                    return EditDriverInfo(
//                      dID: dID,
//                    );
//                  }));
                },
              ),
            ),
          ],
        ),
//      body: showAllInfo(),
//      body: _scaffoldBodyOptions.elementAt(_selectedIndex),
      body: StreamBuilder(
        stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          return showAllInfo(snapshot.data.documents[0]);
        },
      ),
      resizeToAvoidBottomPadding: false,
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//
//        },
//        child: Icon(Icons.gps_fixed),
//        tooltip: 'Xác định vị trí xe đang ở',
//      ),

    );
  }

  Widget showAllInfo(driver) {
    return Column(
      children: <Widget>[
        showBasicInfo(driver['name'], 'Đang làm việc', '0.5%'),
        Expanded(
            child: showDetails( driver['dID'], driver['idCard'],
                driver['address'], driver['email'],
                driver['gender'], driver['dob'])
        ),
        generatePasswordButton(),

      ],
    );
  }

  Widget showBasicInfo(name, status, alcohol) {
    return Container(
        height: 120.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 15.0),
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
                      child: Text("$name", style: driverNameStyle()),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        children: <Widget>[
                          Text("Trạng thái: ", style: driverStatusTitleStyle(0)),
                          Text("$status", style: driverStatusDataStyle(0)),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text("Nồng độ cồn: ", style: driverStatusTitleStyle(0)),
                        Text("$alcohol", style: driverStatusDataStyle(0)),
                      ],
                    ),
                  ],
                )
            )

          ],
        )

    );
  }

  Widget generatePasswordButton() {
    return Container(
      height: 45.0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),
      child: RaisedButton(
        child: Text(
            "Tạo mật khẩu mới",
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
            )
        ),
        elevation: 6.0,
        onPressed: () {
          //action
          debugPrint("New pw generated");
        },
      ),
    );
  }
}

Widget showDetails(id, idCard, address, email, gender, dob) {
  final df = new DateFormat('dd/MM/yyyy');
  var formattedDOB = df.format(dob.toDate());
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showDetailItem('ID', id, 1),
//            showDetailInfo('Tuổi', '40', 0 ),
              showDetailItem('CMND', idCard, 0),
              showDetailItem('Địa chỉ', address, 1),
              showDetailItem('Email', email, 0),
              showDetailItem('Giới tính', gender=='M'?'Nam':'Nữ', 1 ),
              showDetailItem('Ngày sinh', formattedDOB, 0),
            ],
          )
      )
  );

}

Widget showDetailItem(title, data, line) {
  return Row(
    children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
            height: 55.0,
//          margin: const EdgeInsets.all(5.0),
            padding: EdgeInsets.only(left: 25.0),
            decoration: line == 1 ? oddLineDetails() : evenLineDetails(), //             <--- BoxDecoration here
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$data",
              style: driverInfoStyle(),
            ),

          ),
        ),
      ),
    ],

  );
}


