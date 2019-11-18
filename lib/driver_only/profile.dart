import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alcohol_management/root_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

//enum AuthStatus {
//  notDetermined,
//  notSignedIn,
//  signedIn
//}

class ShowDriverInfo extends StatefulWidget {
  final String dID;
  const ShowDriverInfo({Key key, @required this.dID,}) : super(key: key);
  @override
  _ShowDriverInfoState createState() => _ShowDriverInfoState(dID);
}


class _ShowDriverInfoState extends State<ShowDriverInfo> {
  String dID;
  String _url;
  _ShowDriverInfoState(this.dID);


  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  void initState(){
    getImageUrl();
  }
  getImageUrl() async {
    final ref = FirebaseStorage.instance.ref().child(dID);
    var url = await ref.getDownloadURL();
    setState(() {
      print("URL:" + url);
      _url = url;
    });
  }


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
                driver['basicInfo']['gender'], driver['basicInfo']['dob'], driver['basicInfo']['tel'])
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            signoutButton(context),
            Container(width: 50,),
            generatePasswordButton(),
          ],
        ),


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
            Row(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 15.0),
                    child: CircleAvatar(
                      radius: 45.0,
                      //backgroundColor: Colors.blue,
                      backgroundImage: AssetImage('images/avatar.png'),
                      child: ClipOval(
                          child:
                            SizedBox(
                              height: 100.0,
                              width: 100.0,
                              child:  (_url != null)?
                                Image.network(
                                  //"https://thumbs.gfycat.com/HastyResponsibleLeopard-mobile.jpg",
                                    _url,
                                    fit: BoxFit.cover
                                ): SizedBox(
                                  height: 100.0,
                                  width: 100.0,

                                )
                            )
                      ),
                    )
//                Padding(
//                  padding: EdgeInsets.only(top: 60.0),
//                  child: IconButton(
//                    icon: Icon(
//                      FontAwesomeIcons.camera,
//                      size: 20.0,
//                    ),
//                    onPressed: () {
//
//                      //getImage();
//                    },
//                  ),
                )
              ],
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
  Widget signoutButton(context) {
    return Container(
      height: 45.0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),
      child: RaisedButton(
        color: Color(0xff0a2463),
        child: Text(
          "Đăng xuất",
          style: TextStyle(color: Colors.white, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        elevation: 6.0,
        onPressed: () {
          //action
          try{
//            final FirebaseAuth auth = AuthProvider.of(context).auth;
//            await auth.signOut();
//            onSignedOut();
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RootPage())
            );
          } catch (e){
            print(e);
          }
        },
      ),
    );
  }
}

Widget showDetails(id, idCard, address, email, gender, dob, tel) {
  var formattedDOB = DateFormat('dd/MM/yyyy')
      .format(DateTime.fromMillisecondsSinceEpoch(dob))
      .toString();
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showDetailItem('ID', id, 1),
              showDetailItem('Sđt', tel, 0),
              showDetailItem('CMND', idCard, 1),
              showDetailItem('Địa chỉ', address, 0),
              showDetailItem('Email', email, 1),
              showDetailItem('Giới tính', gender=='M'?'Nam':'Nữ', 0 ),
              showDetailItem('Ngày sinh', formattedDOB, 1),
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