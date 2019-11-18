import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showDriverInfoScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

//import 'package:path/path.dart';


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
  String _url;
  File _image;
  _EditDriverInfoState(this.dID);


  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();

  var driver;
  int genderRadioGroup;
  int dob;
  bool isInit = true;
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _nameController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void initState(){
    getImageUrl();
  }
  getImageUrl() async {
    final ref = FirebaseStorage.instance.ref().child(dID);
    try {
      var url = await ref.getDownloadURL();
      setState(() {
        print("URL:" + url);
        _url = url;
      });
    } catch (e){
      _url = null;
    }

  }


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }


  Future uploadPic() async{
    String fileName = dID;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    await uploadTask.onComplete;

    print("Profile Picture uploaded");
//    setState(() {
//      print("Profile Picture uploaded");
//      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
//    });
  }

  Widget build(BuildContext context) {
    if(_selectedFunction == -1) {

      return ShowDriverInfo(
        key: PageStorageKey("showInfo"),
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
//            setState(() {
//              _selectedFunction--;
//            });
            Navigator.pop(context);
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
                  Navigator.of(context).pop();
                  editDataDTB();

                  Fluttertoast.showToast(msg: 'Đã thay đổi thông tin tài xế');
//                dispose();
                }

              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('driver').child(dID).onValue,
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);

          driver = snapshot.data.snapshot.value['basicInfo'];
          _nameController.text = driver['name'];
          _addressController.text = driver['address'];
          _idCardController.text = driver['idCard'].toString();
          if(isInit) {
            genderRadioGroup = driver['gender']=='M'?0:1;
            dob = driver['dob'];
            isInit = false;
          }

          return editAllInfo(driver);
        },
      ),
//      resizeToAvoidBottomPadding: false,
    );
  }

  Widget editAllInfo(driver) {

    return Column(
      children: <Widget>[
        editBasicInfo(),

        Expanded(
            child: Container(
              child: editDetails(dID, driver['email']),
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
              child: FlatButton(
                  onPressed: (){
                    print("Avatarrrrr");
                      getImage();
                  },
                  child: CircleAvatar(
                    radius: 45.0,
//                    backgroundColor: Colors.blue,
                    backgroundImage: AssetImage('images/avatar.png'),
                    child:
                    ClipOval(
                        child: SizedBox(
                          width: 180.0,
                          height: 180.0,
                          child: (_image!=null)?Image.file(
                            _image,
                            fit: BoxFit.cover,
                          ): (_url != null)?
                          Image.network(
                            //"https://is2-ssl.mzstatic.com/image/thumb/Purple123/v4/1c/bd/55/1cbd550d-80f9-6d4b-01f0-44eb73c99520/pr_source.png/512x512bb.jpg",
                            _url,
                            fit: BoxFit.cover,
                          ):
                          SizedBox(
                            height: 100.0,
                            width: 100.0,
                          ),
                        )
                    ),

                  )
              ),
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
                editDetailItem('Giới tính', 1, null),
                editDetailItem('Ngày sinh',  0, null),
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

  void editDataDTB() async{
    await uploadPic();
    FirebaseDatabase.instance.reference()
        .child('driver')
        .child(dID).child('basicInfo')
        .update({
      'name' : _nameController.text,
      'idCard' : _idCardController.text,
      'address' : _addressController.text,
      'gender' : genderRadioGroup == 0 ? 'M' : 'F',
      'dob' : dob,
    });

    //maybe transaction here???
//    FirebaseDatabase.instance.reference()
//        .child('driver')
//        .child(dID).runTransaction((transaction) async{
//      DocumentSnapshot freshSnap =
//        await transaction.get(driver.reference);
//      await transaction.update(freshSnap.reference, {
//        'name' : _nameController.text,
//        'idCard' : _idCardController.text,
//        'address' : _addressController.text,
//        'gender' : _genderController.text == 'Nam' ? 'M' : 'F',
//        'dob' : formattedDOB,
//      });
//    });
  }
}






