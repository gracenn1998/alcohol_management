import 'package:flutter/material.dart';
//import 'package:alcohol_management/show_info_screens/driver_showTrips.dart';
import 'package:alcohol_management/show_info_screens/driver_showHistory.dart';
import '../driver_only/profile.dart';
import '../driver_only/show_tasks.dart';
import '../driver_only/show_history.dart';
import '../driver_only/showTripDetails.dart';

class DriverMenu extends StatefulWidget {
  DriverMenu ({Key key}) : super (key:key);
  @override
  _DriverMenuState createState() => _DriverMenuState();
}

class _DriverMenuState extends State<DriverMenu>{
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ShowTasks(
        filterState:0
    ),
    ShowTripDetails(
      tID: 'HT0004',
    ),
    Text(
      'Thong Bao',
      style: optionStyle,
    ),
    ShowDriverInfo(
      dID: 'TX0003'
    ),
    ShowHistory(
        filterState:0
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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