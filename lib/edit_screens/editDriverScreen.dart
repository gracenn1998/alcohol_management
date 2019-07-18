import 'package:flutter/material.dart';
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
  int _selectedFunction = 0;
  String dID;
  _EditDriverInfoState(this.dID);


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

      return ShowDriverInfo(
        key: PageStorageKey("showInfo"),
        dID: driver['dID'],
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
              _selectedFunction--;
            });
          },
        ),
        title:  Center(child: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,)),
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
                  editDataDTB(driver);
                  setState(() {
                    _selectedFunction--;
                  });
//                dispose();
                }

              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          driver = snapshot.data.documents[0];
          _nameController.text = driver['name'];
          _addressController.text = driver['address'];
          _idCardController.text = driver['idCard'];
          _genderController.text = driver['gender']=='M'?'Nam':'Nữ';

          final df = new DateFormat('dd/MM/yyyy');
          var formattedDOB = df.format(driver['dob']);
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

  void editDataDTB(DocumentSnapshot driver) {
    DateTime formattedDOB =  DateFormat("dd/MM/yyyy").parse(_dobController.text);
    
    Firestore.instance.runTransaction((transaction) async{
      DocumentSnapshot freshSnap =
        await transaction.get(driver.reference);
      await transaction.update(freshSnap.reference, {
        'name' : _nameController.text,
        'idCard' : _idCardController.text,
        'address' : _addressController.text,
        'gender' : _genderController.text == 'Nam' ? 'M' : 'F',
        'dob' : formattedDOB,
      });
    });
  }
}






