import 'package:flutter/material.dart';
//import 'package:alcohol_management/show_info_screens/driver_showTrips.dart';
import '../driver_only/profile.dart';
import '../driver_only/show_tasks.dart';
import '../driver_only/show_history.dart';
import '../driver_only/WorkingTripDetail.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverMenu extends StatefulWidget {
  final String dID;
  DriverMenu ({Key key, @required this.dID}) : super (key:key);
  @override
  _DriverMenuState createState() => _DriverMenuState(dID);
}

class _DriverMenuState extends State<DriverMenu>{
  String dID;
  _DriverMenuState(this.dID);

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      ShowTasks(
        dID: dID,
      ),
      D_WorkingTripDetail(
        dID: dID,
      ),
      Text(
        'Thong Bao',
        style: optionStyle,
      ),
      ShowDriverInfo(
        dID: dID,
      ),
      ShowHistory(
        dID: dID,
      ),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type : BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Danh sách'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            title: Text('Hành trình'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Thông báo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Cá nhân'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('Lịch sử'),
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