import 'package:flutter/material.dart';
import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/show_info_screens/showAllJourneys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "../show_info_screens/showDriverInfoScreen.dart";
import 'package:alcohol_management/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBottomMenu extends StatefulWidget {
  MyBottomMenu ({Key key}) : super (key:key);
  @override
  _MyBottomMenuState createState() => _MyBottomMenuState();
}

class _MyBottomMenuState extends State<MyBottomMenu>{
  int notiCount = 0;
  int _selectedIndex = 0;
  var _selectedDriverID = null;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ShowAllDrivers(
        key: PageStorageKey('showAll')
    ),
    ShowAllTrips(), //Trips screen
    Text(
      'Nhan Vien',
      style: optionStyle,
    ),
    NotiScreen(), //Notification Screen
    Text(
      'Ca Nhan',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 3){
        if (notiCount > 0 ){
          notiCount--;
        }
      }
    });
  }

  FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fcm.subscribeToTopic('alcoholTracking');


    _fcm.configure(
      onMessage: (Map<String, dynamic> msg) {
        print("onMessage: $msg");
        print(_selectedDriverID);
        setState(() {
          writeNoti(msg['data']['lastNotiTime'], msg['data']['dID'],
              msg['data']['tripID'], msg['notification']['body']);
        });
        notiCount++;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(msg['notification']['title']),
                subtitle: Text(msg['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Xem thông tin tài xế'), //sau chỉnh thành thông tin hành trình
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ShowDriverInfo(
                                key: PageStorageKey("showInfo"),
                                dID: msg['data']['dID'],
                              )
                      )
                    );
                    Navigator.of(context).pop();
                    if (notiCount > 0 ){
                      notiCount--;
                    }
                  },
                ),
                FlatButton(
                  child: Text('Ok'), //sau chỉnh thành thông tin hành trình
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )

              ],
            )
        );
      },
      onResume: (Map<String, dynamic> msg) {
        print("onResume: $msg");
      },
      onLaunch: (Map<String, dynamic> msg) {
        print("onLaunch: $msg");
      },
    );

    _fcm.requestNotificationPermissions(
        IosNotificationSettings(

        )
    );
  }

  @override
  Widget build(BuildContext context) {
//    if (_selectedDriverID != null) {
//      String id = _selectedDriverID;
//      _selectedDriverID = null;
//      return ShowDriverInfo(
//        key: PageStorageKey("showInfo"),
//        dID: id,
//      );
//    }

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type : BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text('Tài xế'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            title: Text('Hành trình'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            title: Text('Nhân viên'),
          ),
          BottomNavigationBarItem(
            icon: new Stack(
              children: <Widget>[
                new Icon(Icons.notifications),
                new Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: notiCount == 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$notiCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            title: Text('Thông báo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Cá nhân'),
          ),
        ],
        backgroundColor: Colors.white,
        unselectedItemColor: Color.fromRGBO(10,36,99,0.4),
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff0a2463),
        onTap: _onItemTapped,
      ),
    );
  }
  void writeNoti(lastNotiTime, dID, tripID, body) {
    var docRef = Firestore.instance
        .collection('bnotification')
        .document();

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        docRef,
        {
          'timeCreated': DateTime.now().millisecondsSinceEpoch.toString(),
          'dID': dID,
          'tripID': tripID,
          'lastNotiTime': lastNotiTime,
          'body': body
        },
      );
    });
  }
}