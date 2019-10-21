import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../show_info_screens/showAllTrips.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
  var streamSub;
  var latestID, newID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamSub = FirebaseDatabase.instance.reference().child('trips')
        .onChildAdded.listen((data) {
       latestID = data.snapshot.value['tID'];
       newID = getNewTripID(latestID);
    });
  }

  void dispose() {
    // Clean up the controller when the Widget is disposed
    _fromController.dispose();
    _toController.dispose();
    _schController.dispose();
    streamSub.cancel();
    super.dispose();
  }

  Widget build(BuildContext build)
  {
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
                    Fluttertoast.showToast(msg: 'Đã thêm hành trình');
                    Navigator.pop(context);
//                dispose();
                  }

                },
              ),
            ),
          ],
        ),
//        resizeToAvoidBottomInset: false,
        body:
         //Center(child: Text("Bodyyyy"),)
          fillDetails()

      );
  }

  Widget EditTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        showTripID(trip['tID']),
        Expanded(
          child: fillDetails(),
        )
      ],
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
                fillDetailInfo('Thời gian bắt đầu dự kiến', 1, _schController),
              ],
            )
        )
    );

  }

  int startTime = -1;
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
            child:
              title=='Thời gian bắt đầu dự kiến'
                  ? FlatButton(
                  onPressed: () {
//                    DatePicker.showDatePicker(context,
//                        showTitleActions: true,
//                        minTime: DateTime(1950, 1, 1),
//                        maxTime: DateTime.now(),
//                        onConfirm: (date) {
//                          setState(() {
//                            dob = date.millisecondsSinceEpoch;
//                          });
//                        }, currentTime: DateTime.now(), locale: LocaleType.vi);
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        currentTime: DateTime.now(),
                        locale: LocaleType.vi,
                        onConfirm: (datetime) {
                          setState(() {
                            startTime = datetime.millisecondsSinceEpoch;
                          });
                        }
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        startTime==-1?'Bấm để chọn thời gian': DateFormat('dd/MM/yyyy kk:mm')
                            .format(DateTime.fromMillisecondsSinceEpoch(startTime))
                            .toString(),
                        style: driverInfoStyle(),
                      ),
                      IconButton(
                          icon: Icon(Icons.calendar_today)
                      )
                    ],
                  ))
                  :
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
    var isAddCalled = false;
//    var schMilli = DateFormat('dd/MM/yyyy kk:mm').parse(_schController.text).millisecondsSinceEpoch;
//    schMilli+=3600000; //no idea :(

    FirebaseDatabase.instance.reference().child('trips').child(newID)
        .set({
      'tID' : newID,
      'isDeleted' : false,
      'schStart' : startTime,
      'from': _fromController.text,
      'to': _toController.text,
      'status': 'notStarted',
    }).then((data) {
      streamSub.cancel();
    });
//    isAddCalled = true;
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
