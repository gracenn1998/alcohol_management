import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _appBarRightIconOptions = <Widget>[
    Icon(Icons.edit),
    Icon(Icons.check),
  ];
  
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if(_selectedIndex == -1) {
      return Center(
          child: Text(
            'List Tai Xe',
            style: optionStyle,
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
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
          title:  Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,),
          trailing: IconButton(
            icon: _appBarRightIconOptions.elementAt(_selectedIndex),
            color: Color(0xff06E2B3),
            onPressed: () {
              //editttt
              setState(() {
                if(_selectedIndex == 0) {
                  _selectedIndex = 1;
                }
                else {
                  //save to DTB....
                  //back to show info page
                  _selectedIndex = 0;
                }
              });
            },
          ),
        ),
      ),
//      body: showAllInfo(),
//      body: _scaffoldBodyOptions.elementAt(_selectedIndex),
      body: StreamBuilder(
        stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Text('loading...');
          if(_selectedIndex == 0) {
            return showAllInfo(snapshot.data.documents[0]);
          }
          return editAllInfo(snapshot.data.documents[0]);
        },
      )
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//
//        },
//        child: Icon(Icons.gps_fixed),
//        tooltip: 'Xác định vị trí xe đang ở',
//      ),

    );
  }
}

Widget showAllInfo(driver) {
//  Firestore.instance
//      .collection('drivers')
//      .where("dID", isEqualTo: "TX0001")
//      .snapshots()
//      .listen((data) =>
//      data.documents.forEach((doc) => print(doc["name"])));
  return Column(
    children: <Widget>[
      Expanded(
        flex: 6,
        child: showBasicInfo(driver['name'], 'Đang làm việc', '0.5%'),
      ),
      Expanded(
        flex: 19,
        child: showDetails( driver['dID'], driver['idCard'],
                            driver['address'], driver['email'],
                            driver['gender'], driver['dob'])
      ),
      Expanded(
        flex: 3,
        child: generatePasswordButton(),
      ),

    ],
  );
}

Widget showBasicInfo(name, status, alcohol) {
  return Container(
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

Widget showDetails(id, idCard, address, email, gender, dob) {
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            showDetailInfo('ID', id, 1),
//            showDetailInfo('Tuổi', '40', 0 ),
            showDetailInfo('CMND', idCard, 0),
            showDetailInfo('Địa chỉ', address, 1),
            showDetailInfo('Email', email, 0),
            showDetailInfo('Giới tính', gender=='M'?'Nam':'Nữ', 1 ),
            showDetailInfo('Ngày sinh', dob, 0),
          ],
        )
      )
  );

}

Widget showDetailInfo(title, data, line) {
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
          padding: EdgeInsets.only(left: 15.0),
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


Widget generatePasswordButton() {
  return Container(
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

BoxDecoration myBoxDecorationOddLine() {
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

BoxDecoration myBoxDecorationEvenLine() {
  return BoxDecoration(
    border: Border(
      left: BorderSide(
        color: Color(0xffDCDEE0),
        width: 1.0,
      )

    ),
    color: Colors.white

  );
}
