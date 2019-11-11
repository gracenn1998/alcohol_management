import 'package:flutter/material.dart';
import 'TripDetails-style-n-function.dart';
import '../styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:alcohol_management/show_info_screens/showDriverInfoScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TripStatus extends StatefulWidget {
  final tID;
  final driver;
  const TripStatus({Key key, @required this.tID, @required this.driver}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TripStatusState(tID, driver);
}

class _TripStatusState extends State<TripStatus> {
  final tID;
  final driver;
  var choice;
  var _trip;
  _TripStatusState(this.tID, this.driver);
  @override
  void initState() {
    super.initState();
  }


  void setTripStatus(id, driver, status) {
    if (status == 0){
      FirebaseDatabase.instance.reference()
          .child('trips')
          .child(id)
          .update({
        'status': "working"
      });
    } else if(status == 1) {
      FirebaseDatabase.instance.reference()
          .child('trips')
          .child(id)
          .update({
        'status': "done"
      });
    } else {
      FirebaseDatabase.instance.reference()
          .child('trips')
          .child(id)
          .update({
        'status': "aborted"
      });
    }
  }

  _showTripStatusContent(tID){
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Đặt trạng thái hành trình", style: appBarTxTStyle,),),
      ),
      body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.maxFinite,
              height: 150,
              child: ListView(
                children: <Widget>[
                  RadioListTile(
                      title: Text("Tiếp tục hành trình " + tID),
                      value: 0,
                      groupValue: choice,
                      onChanged: (val) {
                        setState(() {
                          choice = val;
                        });
                      }
                  ),
                  RadioListTile(
                      title: Text("Hoàn tất hành trình " + tID),
                      value: 1,
                      groupValue: choice,
                      onChanged: (val) {
                        setState(() {
                          choice = val;
                        });
                      }
                  ),
                  RadioListTile(
                      title: Text("Hủy hành trình " + tID),
                      value: 2,
                      groupValue: choice,
                      onChanged: (val) {
                        setState(() {
                          choice = val;
                        });
                      }
                  ),
                ],
              ),
            ),
            Container(
              child: Center(
                child: RaisedButton(
                  onPressed: () {
                    setTripStatus(tID, driver, choice);
                    Fluttertoast.showToast(
                        msg: "Đã lưu trạng thái hành trình",
                        gravity: ToastGravity.TOP,
                        fontSize: 16.0);
                    Navigator.pop(context);
                  },
                  child: Text("Lưu", style: TextStyle(fontSize: 15)),
                ),
              )
            )
          ],
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('trips')
          .child(tID)
          .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        _trip = snapshot.data.snapshot.value;
        // print("Build func: streambuilder on Firestore_______________________________");

        return _showTripStatusContent(tID);
      },
    );
  }
}

