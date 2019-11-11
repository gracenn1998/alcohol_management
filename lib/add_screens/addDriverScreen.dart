import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showAllDrivers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddDriver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddDriver();
  }
}

class _AddDriver extends State<AddDriver> {
  int _selectedFunction = 0;
  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();

  DocumentSnapshot driver;

  var streamSub;
  var latestID, newID;
  var isAddCalled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamSub = FirebaseDatabase.instance.reference().child('driver')
        .onChildAdded.listen((data) {
          if(!isAddCalled) {
            latestID = data.snapshot.value['dID'];
            newID = generateNewDriverID(latestID);
          }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _nameController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if(_selectedFunction == -1) {

      return ShowAllDrivers(
        key: PageStorageKey("showAll")
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            //backkkk
            Navigator.pop(context);
          },
        ),
        title:  Center(child: Text('Thêm tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.check, size: 30.0,),
              color: Color(0xff06E2B3),
              onPressed: () {
                //confirm edit
                var confirmed = 1;
                if(confirmed == 1) {
                  addDataDTB();
                  Fluttertoast.showToast(msg: 'Đã thêm tài xế');
                  Navigator.pop(context);
//                dispose();
                }

              },
            ),
          ),
        ],
      ),
//      resizeToAvoidBottomInset: false,
      body: showAddInfo(),

    );
  }


  Widget showAddInfo() {

    return Column(
      children: <Widget>[
        fillBasicInfo(),

        Expanded(
            child: Container(
              child: fillDetails()
            )
        ),
      ],
    );
  }

  Widget fillBasicInfo() {

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
                          style: driverNameStyle(),
                          decoration: InputDecoration(
                            hintText: "Tên tài xế",
                          )
                      ),
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
        height: 395.0,
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                fillDetailInfo('CMND', 1, _idCardController),
                fillDetailInfo('Địa chỉ', 0, _addressController),
                fillDetailInfo('Giới tính', 1, null),
                fillDetailInfo('Ngày sinh', 0, null),
              ],
            )
        )
    );

  }
  int genderRadioGroup = 0;
  int dob = -1;
  Widget fillDetailInfo(title, line, controller) {
    var formattedDOB = DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(dob))
        .toString();

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
            child:
              title=='Giới tính'
                  ? Row(
                    children: <Widget>[
                      Radio(
                          value: 0,
                          groupValue: genderRadioGroup,
                          onChanged: (val) => setState((){
                            genderRadioGroup = val;
                          })),
                      Text('Nam', style: driverInfoStyle()),
                      Radio(
                          value: 1,
                          groupValue: genderRadioGroup,
                          onChanged: (val) => setState((){
                            genderRadioGroup = val;
                          })),
                      Text('Nữ', style: driverInfoStyle())

                    ],
                  ):
              title == 'Ngày sinh'
                  ? FlatButton(
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(1950, 1, 1),
                        maxTime: DateTime.now(),
                        onConfirm: (date) {
                          setState(() {
                            dob = date.millisecondsSinceEpoch;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.vi);
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        dob==-1?'Bấm để chọn ngày sinh': DateFormat('dd/MM/yyyy')
                            .format(DateTime.fromMillisecondsSinceEpoch(dob))
                            .toString(),
                        style: driverInfoStyle(),
                      ),
                      Icon(Icons.calendar_today)
                    ],
                  )):
                TextFormField(
                  controller: controller,
                  style: driverInfoStyle(),
                ),


          ),
        ),
      ],

    );
  }

  void addDataDTB () async {
//    var dobMilli = DateFormat('dd/MM/yyyy').parse(_dobController.text).millisecondsSinceEpoch;

    FirebaseDatabase.instance.reference().child('driver').child(newID)
        .set({
          'dID' : newID,
          'isDeleted' : false,
          'alcoholVal' : -1,
    }).then((data) {
      streamSub.cancel();
      FirebaseDatabase.instance.reference().child('driver').child(newID).child('basicInfo')
        .set({
          'name' : _nameController.text,
          'idCard' : _idCardController.text,
          'address' : _addressController.text,
          'gender' : genderRadioGroup == 0 ? 'M' : 'F',
          'dob' : dob,
          'email' : newID.toLowerCase() + '@driver.potatoes.com',
      });
    });
    isAddCalled = true;

    //need transaction....

//    Firestore.instance.runTransaction((transaction) async{
//      await transaction.set(Firestore.instance.collection("drivers").document(newID), {
//        'name' : _nameController.text,
//        'idCard' : _idCardController.text,
//        'address' : _addressController.text,
//        'gender' : _genderController.text == 'Nam' ? 'M' : 'F',
//        'dob' : formattedDOB,
//        'dID' : newID,
//        'email' : newID.toLowerCase() + '@driver.potatoes.com',
//      });
//    }).then((data){
//      streamSub.cancel();
//    });
  }

  String generateNewDriverID(String lastID) {
    //generate new id
    String idCounter = (int.parse(lastID.substring(3)) + 1).toString();
    while(idCounter.length < 4) {
      idCounter = '0' + idCounter;
    }
    String newID = 'TX' + idCounter;

    return newID;
  }

}




