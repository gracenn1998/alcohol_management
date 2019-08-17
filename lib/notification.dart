import 'package:alcohol_management/show_info_screens/showDriverInfoScreen.dart';
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
  }

  Widget getListNoti(document) {
    var listView = ListView.separated(
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedNoti = document[index].data['dID'];
              notiIsTapped = 0;
            });
          },
          child: Container(
            color: document[index].data['isTapped'] ? Colors.white : Color(
                0xffCBE7FF),
            padding: EdgeInsets.only(
                left: 25.0, top: 15.0, right: 25.0, bottom: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: 'Tài xế ', style: notiTxtStyle),
                        TextSpan(text: document[index].data['dID'],
                            style: notiHightlight),
                        TextSpan(
                            text: ' có dấu hiệu vượt mức nồng độ cồn trong hành trình ',
                            style: notiTxtStyle),
                        TextSpan(text: document[index].data['tripID'],
                            style: notiHightlight)
                      ]
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document[index].data['timeCreated'])))
                      .toString(),
                  style: notiTimeStyle,
                ),
              ],
            ),
          ),
        );
      },
      itemCount: document.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 1.0,
        );
      },
    );
    return listView;
  }
}