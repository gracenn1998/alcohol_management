import 'package:flutter/material.dart';
import './show_info_screens/showAllDrivers.dart';

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
    Text(
      'Hanh Trinh',
      style: optionStyle,
    ),
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
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff0a2463),
        onTap: _onItemTapped,
      ),
    );
  }
}