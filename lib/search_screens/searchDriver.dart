import 'package:alcohol_management/show_info_screens/showAllDrivers.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import "../show_info_screens/showDriverInfoScreen.dart";

class SearchDriver extends StatefulWidget {
  const SearchDriver() : super();

  @override
  State<StatefulWidget> createState() {
    return _searchDriverState();
  }
}

class _searchDriverState extends State<SearchDriver> {

  String driverName = "";

  Icon icon = Icon(Icons.search);
  Widget appBarTittle = Text(
    'Tìm kiếm Tài xế',
    style: appBarTxTStyle,
  );
  TextEditingController _controller = new TextEditingController();
  String _searchText = '';
  bool _searching = true;
  List<dynamic> driverList;
//  List<dynamic> searchResults;
  var queryResultSet = [];
  var tmpSearchStore = [];

  _searchDriverState() {
    _controller.addListener(() {
      setState(() {
//        searchWithKeyWord(_controller.text);
      });
    });
  }

  List<dynamic> searchWithKeyWord(String keyword) {
    List<dynamic> searchResult = new List<dynamic>();
    keyword = keyword.toLowerCase();
    String name, did;
    for(int i = 0; i < driverList.length; i++) {
      name = driverList[i]['basicInfo']['name'].toString().toLowerCase();
      did = driverList[i]['dID'].toString().toLowerCase();

      if(name.contains(keyword) || did.contains(keyword)) {
        searchResult.add(driverList[i]);
      }
    }
    return searchResult;
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
              Icons.arrow_back_ios,
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
          stream:
            FirebaseDatabase.instance.reference().child('driver')
                .orderByChild('basicInfo/name')
//                .startAt(_controller.text.toUpperCase()).endAt(_controller.text.toLowerCase() + '\uf8ff')
                .onValue,
          builder: (BuildContext context, AsyncSnapshot snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
            }
            else {
              DataSnapshot driverSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = driverSnaps.value;
              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
              if (map != null) { /*To not show the deleted drivers*/
                driverList = map.values.toList();
                for (int i = 0; i<driverList.length; ++i) {
                  debugPrint(driverList[i]['isDeleted'].toString());
                  if (driverList[i]['isDeleted']) driverList.removeAt(i);
                }
              }
              //..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));
              return getListSearchView(searchWithKeyWord(_controller.text));
            }
          },
        )
            : StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver')
              .orderByChild('isDeleted').equalTo(false)
              .onValue,
          builder: (BuildContext context, AsyncSnapshot snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
            else {
              List<dynamic> driverList;
              DataSnapshot driverSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = driverSnaps.value;
              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
              if (map != null) driverList = map.values.toList();//..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));

              return  getListSearchView(driverList);
            }
          },
        )
    );
  }

  Widget getListSearchView(documents) {
    if(documents == null || documents.length == 0)
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) {},
          separatorBuilder: (context, index) {},
          itemCount: 0
      );

    return ListView.separated(
      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        debugPrint('${documents.length} in body');
        String name = documents[index]['basicInfo']['name'].toString();
        String dID = documents[index]['dID'].toString();
        return InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                          color: const Color(0xff000000),
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 24.0),
                    ),
                    Text(
                      " {$dID}",
                      style: const TextStyle(
                          color: const Color(0xff000000),
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 24.0),
                    )
                  ],
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
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowDriverInfo(
                    key: PageStorageKey('showInfo'),
                    dID: dID))
            );
//            debugPrint('Driver tapped');
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }
}

