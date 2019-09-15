import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:  Center(child: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('driver').child(dID).onValue,
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          return showAllInfo(snapshot.data.snapshot.value);
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
        showBasicInfo(driver),
        Expanded(
            child: showDetails( driver['dID'], driver['basicInfo']['idCard'],
                driver['basicInfo']['address'], driver['basicInfo']['email'],
                driver['basicInfo']['gender'], driver['basicInfo']['dob'])
        ),
        generatePasswordButton(),

      ],
    );
  }

  Widget showBasicInfo(driver) {
    String onWorking, alcoholTrack;
    int status = -1;
    var alcoholVal =  driver['alcoholVal'];

    if(alcoholVal < 0) {
      onWorking = 'Đang nghỉ';
      alcoholTrack = 'Không hoạt động';
      status = -1;
    }
    else {
      if(alcoholVal <= 350) {
        onWorking = 'Đang làm việc';
        alcoholTrack = alcoholVal.toString();
        status = 0;
      }
      else {
        onWorking = 'Say xỉn';
        alcoholTrack = alcoholVal.toString();
        status = 1;
      }
    }

    return Container(
        height: 120.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 15.0),
                child: CircleAvatar(
                  radius: 45.0,
                  backgroundImage: AssetImage('images/avatar.png'),
                )
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Text(driver['basicInfo']['name'], style: driverNameStyle()),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(bottom: 5.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text("Trạng thái: ", style: driverStatusTitleStyle(status)),
                                      Text("$onWorking", style: driverStatusDataStyle(status)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text("Chỉ số cồn: ", style: driverStatusTitleStyle(status)),
                                    Text("$alcoholTrack", style: driverStatusDataStyle(status)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
            ),



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
  var formattedDOB = DateFormat('dd/MM/yyyy')
      .format(DateTime.fromMillisecondsSinceEpoch(dob))
      .toString();
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