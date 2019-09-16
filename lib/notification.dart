import 'package:alcohol_management/show_info_screens/showDriverInfoScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

class NotiScreen extends StatefulWidget {
  const NotiScreen() : super();
  @override
  State<StatefulWidget> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int notiIsTapped = 1;
  String _selectedNoti = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  /*Widget build(BuildContext context) {
    if (_selectedNoti != null) {
      String id = _selectedNoti;
      _selectedNoti = null;
      return ShowDriverInfo(
        key: PageStorageKey("showInfo"),
        dID: id,
      );
    }
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: Text(
          'Thông báo', style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('bnotification').orderBy(
            'timeCreated', descending: true).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting)
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          else
            return getListNoti(snapshots.data.documents);
        },
      ),
    );
  }*/
  Widget build(BuildContext context) {
    if (_selectedNoti != null) {
      String id = _selectedNoti;
      _selectedNoti = null;
      return ShowDriverInfo(
        key: PageStorageKey("showInfo"),
        dID: id,
      );
    }
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: Text(
          'Thông báo', style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('bnotification').onValue,
        builder:
            (BuildContext context, snapshots) {
          if (!snapshots.hasData) {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          }
          else{
            List<dynamic> notiList;
            DataSnapshot notiSnaps = snapshots.data.snapshot;
            Map<dynamic, dynamic> notiMap = notiSnaps.value;

            notiList = notiMap.values.toList()..sort((a, b) => b['timeCreated'].compareTo(a['timeCreated']));

            return getListNoti(notiList);
          }
        },
      ),
    );
  }

  Widget getListNoti(notiSnaps) {
    var listView = ListView.separated(
      itemBuilder: (context, index) {
        int t = notiSnaps[index]['timeCreated'];
        String timeCreated = "$t";
        return InkWell(
          onTap: () {
            setState(() {
              _selectedNoti = notiSnaps[index]['dID'];
              notiIsTapped = 0;
            });
          },
          child: Container(
            color: notiSnaps[index]['isSolved'] ? Colors.white : Color(
                0xffCBE7FF),
            padding: EdgeInsets.only(
                left: 25.0, top: 15.0, right: 25.0, bottom: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Tài xế ', style: notiTxtStyle),
                              TextSpan(text: notiSnaps[index]['dID'],
                                  style: notiHightlight),
                              TextSpan(
                                  text: ' có dấu hiệu vượt mức nồng độ cồn trong hành trình ',
                                  style: notiTxtStyle),
                              TextSpan(text: notiSnaps[index]['tripID'],
                                  style: notiHightlight)
                            ]
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy kk:mm')
                            .format(DateTime.fromMillisecondsSinceEpoch(
                            int.parse(timeCreated)))
                            .toString(),
                        style: notiTimeStyle,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: notiSnaps[index]['isSolved'] ? Icon(Icons.check_circle) : Icon(Icons.check_circle_outline),
                    color: notiSnaps[index]['isSolved'] ? Color(0xff00BC94) : Color(0xff8391b3),
                    onPressed: (){
                      String dID = notiSnaps[index]['dID'];
                      int t = notiSnaps[index]['timeCreated'];
                      String timeCreated = "$t";
                      String notiID = dID + timeCreated;
                      setState(() {
                        if (notiSnaps[index]['isSolved']){
                          FirebaseDatabase.instance.reference().child('bnotification').child(notiID)
                              .update({'isSolved': false});
                        } else {
                          FirebaseDatabase.instance.reference().child('bnotification').child(notiID)
                              .update({'isSolved': true});
                        }
                      });
                    },
                  )
                )
              ],
            )
          ),
        );
      },
      itemCount: notiSnaps.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 1.0,
        );
      },
    );
    return listView;
  }
}