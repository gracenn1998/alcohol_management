import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/show_info_screens/showAllTrips.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import "../show_info_screens/showDriverInfoScreen.dart";
import 'package:alcohol_management/notification.dart';
import '../show-trip-details/showTripDetails.dart';
import 'package:alcohol_management/styles/styles.dart';

class ManagerMenu extends StatefulWidget {
  ManagerMenu ({Key key}) : super (key:key);
  @override
  _ManagerMenuState createState() => _ManagerMenuState();
}
//Commit
class _ManagerMenuState extends State<ManagerMenu>{
  int notiCount = 0;
  int _selectedIndex = 0;
  var _selectedDriverID = null;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ShowAllDrivers(
        key: PageStorageKey('showAll')
    ),
    ShowAllTrips(
      key: PageStorageKey('showAll'),
      filterState: 0,
    ), //Trips screen
    NotiScreen(), //Notification Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2){
        if (notiCount > 0 ){
          setState(() {
            notiCount--;
          });
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
          notiCount++;
        });
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(msg['notification']['title'], style: titleStyle,),
                subtitle: Text(msg['notification']['body'], style: subTitleStyle,),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Xem thông tin hành trình đang chạy',),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowTripDetails(
                            key: PageStorageKey('showInfo'),
                            tID: msg['data']['tripID']))
                    );

//                    Navigator.of(context).pop();
                    if (notiCount > 0 ){
                      notiCount--;
                    }
                  },
                ),
                FlatButton(
                  child: Text('Đóng'),
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
        setState(() {
          notiCount++;
        });
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShowTripDetails(
                key: PageStorageKey('showInfo'),
                tID: msg['data']['tripID']))
        );
      },
      onLaunch: (Map<String, dynamic> msg) {
        print("onLaunch: $msg");
        setState(() {
          notiCount++;
        });
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShowTripDetails(
                key: PageStorageKey('showInfo'),
                tID: msg['data']['tripID']))
        );
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
            icon: Stack(
              children: <Widget>[
                Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: notiCount == 0 ? Colors.transparent : Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$notiCount',
                      style: TextStyle(
                        color: notiCount == 0 ? Colors.transparent : Colors.white,
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