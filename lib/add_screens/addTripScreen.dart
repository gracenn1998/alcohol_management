import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showAllJourneys.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTrip extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTripState();
  }
}

class _AddTripState extends State<AddTrip> {
  int _selectedFunction = 0;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _schController = TextEditingController();
  final _driverIDController = TextEditingController();
  final _driverNameController = TextEditingController();

  void dispose() {
    // Clean up the controller when the Widget is disposed
    _fromController.dispose();
    _toController.dispose();
    _schController.dispose();
    _driverIDController.dispose();
    _driverNameController.dispose();
    super.dispose();
  }

  Widget build(BuildContext build)
  {
      if(_selectedFunction == -1) {
        return ShowAllTrips();
          //Center(child: Text("Show all trip"));
      }
     // return Center(child: Text("Loading..."));
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
          title:  Center(child: Text('Thêm hành trình', style: appBarTxTStyle, textAlign: TextAlign.center,)),
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
                    //Fluttertoast.showToast(msg: 'Đã thêm hành trình');
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
        resizeToAvoidBottomInset: false,
        body:
         //Center(child: Text("Bodyyyy"),)
          fillDetails()

      );
  }


  Widget fillDetails() {
    return Container (
        margin: EdgeInsets.only( bottom: 15.0),
        height: 395.0,
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                fillDetailInfo('Từ', 1, _fromController),
                fillDetailInfo('Đến', 0, _toController),
                fillDetailInfo('Thời gian dự kiến', 1, _schController),
                fillDetailInfo('Mã tài xế', 0, _driverIDController),
                fillDetailInfo('Tên tài xế', 1, _driverNameController),
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
    DateTime formattedDOB =  DateFormat("dd/MM/yyyy hh:mm").parse(_schController.text);
    String lastID, newID;

    await Firestore.instance.collection('journeys')
        .orderBy('jID', descending: true).limit(1).getDocuments().then((journeys) {
      lastID = journeys.documents[0].data['jID'];
    });

    //set new id
    newID = getNewTripID(lastID);

    //listen if have changes
    var streamSub = Firestore.instance.collection('journeys')
        .orderBy('jID', descending: true).limit(1).snapshots().listen((journeys){
      lastID = journeys.documents[0]['jID'];
      newID = getNewTripID(lastID);
    });

    Firestore.instance.runTransaction((transaction) async{
      await transaction.set(Firestore.instance.collection("journeys").document(newID), {
        'schStart' : formattedDOB,
        'jID' : newID,
        'deleted': false,
        'from': _fromController.text,
        'to': _toController.text,
        'name': _driverNameController.text,
        'dID': _driverIDController.text,
        'status': 'notStarted'
      });
    }).then((data){
      streamSub.cancel();
    });
  }


  String getNewTripID(String lastID) {
    //generate new id
    String idCounter = (int.parse(lastID.substring(3)) + 1).toString();
    while(idCounter.length < 4) {
      idCounter = '0' + idCounter;
    }
    String newID = 'HT' + idCounter;

    return newID;
  }
}
