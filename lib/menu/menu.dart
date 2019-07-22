import 'package:flutter/material.dart';
import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/show_info_screens/showAllJourneys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "../show_info_screens/showDriverInfoScreen.dart";

class MyBottomMenu extends StatefulWidget {
  MyBottomMenu ({Key key}) : super (key:key);
  @override
  _MyBottomMenuState createState() => _MyBottomMenuState();
}

class _MyBottomMenuState extends State<MyBottomMenu>{
  int _selectedIndex = 0;
  var _selectedDriverID = null;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ShowAllDrivers(
        key: PageStorageKey('showAll')
    ),
    ShowAllTrips(),
    Text(
      'Nhan Vien',
      style: optionStyle,
    ),
    Text(
      'Thong Bao',
      style: optionStyle,
    ),
    Text(
      'Ca Nhan',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        items: const <BottomNavigationBarItem>[
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
            icon: Icon(Icons.notifications),
            title: Text('Thông Báo'),
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
}