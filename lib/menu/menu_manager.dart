import 'package:flutter/material.dart';

class ManagerMenu extends StatefulWidget {
  ManagerMenu ({Key key}) : super (key:key);
  @override
  _ManagerMenuState createState() => _ManagerMenuState();
}

class _ManagerMenuState extends State<ManagerMenu>{
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Tai Xe',
      style: optionStyle,
    ),
    Text(
      'Hanh Trinh',
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
            icon: Icon(Icons.local_library),
            title: Text('Tài Xế'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('Hành Trình'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
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
}