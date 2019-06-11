import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showDriverInfoScreen.dart';

class EditDriverInfo extends StatefulWidget {
  final dID;
  const EditDriverInfo({Key key, @required this.dID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditDriverInfoState(dID);
  }
}

class _EditDriverInfoState extends State<EditDriverInfo> {
  int _selectedIndex = 0;
  String dID;
  _EditDriverInfoState(this.dID);

  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);


  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _nameController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if(_selectedIndex == -1) {

      return ShowDriverInfo(
        dID: 'TX0001',
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
          title: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.check),
            color: Color(0xff06E2B3),
            onPressed: () {
              //confirm edit
              var confirmed = 1;
              if(confirmed == 1) {
                print(_nameController.text);
                setState(() {
                  dispose();
                  _selectedIndex--;
                });
              }

            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          var driver = snapshot.data.documents[0];
          _nameController.text = driver['name'];
          _addressController.text = driver['address'];
          _idCardController.text = driver['idCard'];
          _genderController.text = driver['gender']=='M'?'Nam':'Nữ';

          final df = new DateFormat('dd/MM/yyyy');
          var formattedDOB = df.format(driver['dob'].toDate());
          _dobController.text = formattedDOB.toString();

          return editAllInfo(snapshot.data.documents[0]);
        },
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget editAllInfo(driver) {

    return Column(
      children: <Widget>[
        editBasicInfo(),

        Expanded(
            child: Container(
              child: editDetails(driver['dID'], driver['email']),
            )
        ),

//      Expanded(
//        flex: 3,
//        child: BlankPanel(),
//      ),


      ],
    );
  }

  Widget editBasicInfo() {
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
                        controller: _nameController,
//                        initialValue: name,
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

  Widget editDetails(id, email) {

    return Container (
        margin: EdgeInsets.only( bottom: 15.0),
        height: 395.0,
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showDetailItem('ID', id, 1),
//            editDetailInfo('Tuổi', '40', 0 ),
                editDetailItem('CMND', 0, _idCardController),
                editDetailItem('Địa chỉ', 1, _addressController),
                showDetailItem('Email', email, 0),
                editDetailItem('Giới tính', 1, _genderController),
                editDetailItem('Ngày sinh',  0, _dobController),
              ],
            )
        )
    );

  }

  Widget editDetailItem(title, line, controller) {
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
              controller: controller,
//              initialValue: data.toString(),
              style: driverInfoStyle(),
            ),


          ),
        ),
      ],

    );
  }
}






