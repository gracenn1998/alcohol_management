import 'package:flutter/material.dart';
import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/show_info_screens/showAllJourneys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyBottomMenu extends StatefulWidget {
  MyBottomMenu ({Key key}) : super (key:key);
  @override
  _MyBottomMenuState createState() => _MyBottomMenuState();
}

class _MyBottomMenuState extends State<MyBottomMenu>{
  int _selectedIndex = 0;
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

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(msg['notification']['title']),
                subtitle: Text(msg['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: ()=> Navigator.of(context).pop(),
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