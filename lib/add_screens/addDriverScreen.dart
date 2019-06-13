import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showAllDrivers.dart';

class AddDriver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddDriver();
  }
}

class _AddDriver extends State<AddDriver> {
  int _selectedFunction = 0;

  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();

  DocumentSnapshot driver;

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
    if(_selectedFunction == -1) {

      return ShowAllDrivers();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            //backkkk
            setState(() {
              _selectedFunction--;
            });
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
//                  setState(() {
//                    _selectedFunction--;
//                  });
//                dispose();
                }

              },
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
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
                fillDetailInfo('Giới tính', 1, _genderController),
                fillDetailInfo('Ngày sinh', 0, _dobController),
              ],
            )
        )
    );

  }

  Widget fillDetailInfo(title, line, controller) {
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
              controller: controller,
              style: driverInfoStyle(),
            ),


          ),
        ),
      ],

    );
  }

  void addDataDTB () async {
    DateTime formattedDOB =  DateFormat("dd/MM/yyyy").parse(_dobController.text);
    String lastID, newID;
    //get last driver id
    await Firestore.instance.collection('drivers')
        .orderBy('dID', descending: true).limit(1).getDocuments().then((driver) {
          lastID = driver.documents[0].data['dID'];
    });

    //set new id
    newID = generateNewDriverID(lastID);

    //listen if have changes
    var streamSub = Firestore.instance.collection('drivers')
        .orderBy('dID', descending: true).limit(1).snapshots().listen((driver){
            lastID = driver.documents[0]['dID'];
            newID = generateNewDriverID(lastID);
        });

    Firestore.instance.runTransaction((transaction) async{
      await transaction.set(Firestore.instance.collection("drivers").document(newID), {
        'name' : _nameController.text,
        'idCard' : _idCardController.text,
        'address' : _addressController.text,
        'gender' : _genderController.text == 'Nam' ? 'M' : 'F',
        'dob' : formattedDOB,
        'dID' : newID,
      });
    }).then((data){
      streamSub.cancel();
    });
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




