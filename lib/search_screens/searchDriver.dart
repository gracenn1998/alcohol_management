import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchDriver extends StatefulWidget {
  const SearchDriver() : super();

  @override
  State<StatefulWidget> createState() {
    return _searchDriverState();
  }
}

class _searchDriverState extends State<SearchDriver> {
  Icon icon = Icon(Icons.search);
  Widget appBarTittle = Text(
    'Tìm kiếm Tài xế',
    style: appBarTxTStyle,
  );
  TextEditingController _controller = new TextEditingController();
  String _searchText = '';
  bool _searching = true;
  List<dynamic> _testList;
  List searchResults = new List();
  var queryResultSet = [];
  var tmpSearchStore = [];

  _searchDriverState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _searchText = '';
          // do something ?
        });
      } else {
        setState(() {
          _searchText = _controller.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_searching) {
      return ShowAllDrivers();
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xff06e2b3),
            ),
            onPressed: () {
              setState(() {
                _searching = false;
              });
            },
          ),
          title: TextField(
            controller: _controller,
            style: new TextStyle(color: Colors.white, fontSize: 20.0),
            decoration: new InputDecoration(
              hintText: 'Nhập thông tin...',
              hintStyle: new TextStyle(color: Colors.white, fontSize: 20.0),
            ),
//          onChanged: null,
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.close,
                  color: Color(0xff06e2b3),
                ),
                onPressed: () => _controller.clear())
          ],
        ),
//      buildBar(context),
        body: _controller.text.isNotEmpty
            ?
        StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver')
              .orderByChild('name')
//              .startAt([_controller.text.toString()]).endAt([_controller.text.toString() + '\uf8ff'])
              .onValue,
          builder: (BuildContext context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)));
            }
            else {
              List<dynamic> driverList;

              DataSnapshot driverSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = driverSnaps.value;
              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
//              for(var value in driverSnaps.value.values) {
//                if(!value['isDeleted']) { //show only drivers have not been deleted yet
//                  driverList.add(value);
//                }
//              }
              driverList = map.values.toList();//..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));

              return getListSearchView(driverList);
            }
          },
        )
//        StreamBuilder(
//          stream: Firestore.instance.collection('drivers')
//              .orderBy('name')
//              .startAt([_controller.text]).endAt([_controller.text + '\uf8ff'])
//              .snapshots(),
//          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
//            if (snapshots.connectionState == ConnectionState.waiting) {
//              return Center(
//                  child: Text('Loading...',
//                      style: TextStyle(
//                          fontSize: 30, fontWeight: FontWeight.bold)));
//            } else return getListSearchView(snapshots.data.documents);
//          },
//        )
            : StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver')
//              .orderByChild('isDeleted').equalTo(false)
              .onValue,
          builder: (BuildContext context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)));
            }
            else {
              List<dynamic> driverList;

              DataSnapshot driverSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = driverSnaps.value;
              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
//              for(var value in driverSnaps.value.values) {
//                if(!value['isDeleted']) { //show only drivers have not been deleted yet
//                  driverList.add(value);
//                }
//              }
              driverList = map.values.toList();//..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));

              return  getListSearchView(driverList);
            }
          },
        ));
  }

  Widget getListSearchView(documents) {
    return ListView.separated(
      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        debugPrint('${searchResults.length} in body');
        String name = documents[index]['basicInfo']['name'].toString();
        return InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
                child: Text(
                  name,
                  style: const TextStyle(
                      color: const Color(0xff000000),
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 24.0),
                ),
              ),
//                              Flexible(
//                                child: Container(
//                                  padding: EdgeInsets.only(top: 5.0, right: 5.0),
//                                  child: Icon(
//                                    Icons.event,
//                                    color: Color(0xff8391b3),
//                                    size: 23.0,
//                                  ),
//                                )
//                              ),
//                              Flexible(
//                                child: Container(
//                                  padding: EdgeInsets.only(top: 10.0),
//                                  child: Text('12/07/2019',
//                                              style: TextStyle(
//                                              color: Color(0xff0a2463),
//                                              fontWeight: FontWeight.w400,
//                                              fontFamily: "Roboto",
//                                              fontStyle: FontStyle.normal,
//                                              fontSize: 18.0))),
//                                ),
            ],
          ),
          onTap: () {
            debugPrint('Driver tapped');
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }
}

