import 'package:alcohol_management/show_info_screens/showAllTrips.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchTrip extends StatefulWidget {
  final searchBy;
  const SearchTrip({Key key, @required this.searchBy}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _searchTripState(searchBy);
  }
}

class _searchTripState extends State<SearchTrip> {
  String searchBy;
  Icon icon = Icon(Icons.search);
  Widget appBarTittle = Text('Tìm kiếm Hành Trình', style: appBarTxTStyle);
  TextEditingController _controller = new TextEditingController();
  String _searchText = '';
  bool _searching = true;
  List<dynamic> _testList;
  List searchResults = new List();
  var queryResultSet = [];
  var tmpSearchStore = [];

  _searchTripState(this.searchBy) {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _searchText = '';
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
      return ShowAllTrips(filterState: 0);
    }
//    debugPrint('Tìm bằng: ${searchBy}');

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
              onPressed: () => _controller.clear()
          ),
          SearchByButton(),
        ],
      ),
//      buildBar(context),
      body: _controller.text.isNotEmpty
            ?
      (
          (searchBy == 'Điểm xuất phát')
          ?
          StreamBuilder(
            stream: FirebaseDatabase.instance.reference().child('trips')
                .orderByChild('from')
                .startAt(_controller.text).endAt(_controller.text+'\uf8ff')
                .onValue,
            builder: (BuildContext context, AsyncSnapshot snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
              else {
                List<dynamic> tripList;
                DataSnapshot tripSnaps = snapshots.data.snapshot;
                Map<dynamic, dynamic> map = tripSnaps.value;
                if (map != null) {
                  tripList = map.values.toList();
                  for (int i=0; i<tripList.length; ++i) {
                    if (tripList[i]['isDeleted'])
                      tripList.removeAt(i);
                  }
                }
                return getListSearchView(tripList);
              }
            },
          )
          :
//          (
//            (searchBy == 'Điểm đến')
//                ?
            StreamBuilder(
              stream: FirebaseDatabase.instance.reference().child('trips')
                      .orderByChild('to')
                      .startAt(_controller.text).endAt(_controller.text+'\uf8ff')
                      .onValue,
              builder: (BuildContext context, AsyncSnapshot snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
                else {
                  List<dynamic> tripList;
                  DataSnapshot tripSnaps = snapshots.data.snapshot;
                  Map<dynamic, dynamic> map = tripSnaps.value;
                  if (map != null) {
                    tripList = map.values.toList();
                    for (int i=0; i<tripList.length; ++i) {
                      if (tripList[i]['isDeleted'])
                        tripList.removeAt(i);
                    }
                  }
                  return getListSearchView(tripList);
                }
              },
            )
//                : //searchBy == 'Tài xế'
//            StreamBuilder()
//          )
      )
          :
      StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('trips')
                .orderByChild('isDeleted').equalTo(false)
                .onValue,
        builder: (BuildContext context, AsyncSnapshot snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
          else {
            List<dynamic> tripList;
            DataSnapshot tripSnaps = snapshots.data.snapshot;
            Map<dynamic, dynamic> map = tripSnaps.value;
            if (map != null) tripList = map.values.toList();
            return getListSearchView(tripList);
          }
        },
      )

//            StreamBuilder(
//              stream:
//              Firestore.instance.collection('journeys')
//                        .orderBy('jID')
//                        .startAt([_controller.text]).endAt([_controller.text + '\uf8ff'])
//                        .snapshots(),
//              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
//                if (snapshots.connectionState == ConnectionState.waiting) {
//                  return Center(
//                      child: Text('Loading...',
//                          style: TextStyle(
//                              fontSize: 30, fontWeight: FontWeight.bold)));
//                } else return getListSearchView(snapshots.data.documents);
//              },
//            )
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
        String tID = documents[index]['tID'];
        return InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            new Container(
              padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
              child: Text(
                tID,
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
          debugPrint('Trip tapped');
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  Widget SearchByButton() {
    final List<String> _searchBy = [
      'Điểm xuất phát',
      'Điểm đến',
//      'Tài xế',
    ];

    return PopupMenuButton(
      itemBuilder: (context) => _searchBy.map((option) => PopupMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      initialValue: _searchBy.first,
      onSelected: (value) {
        debugPrint('search by ${value}');
        setState(() {
          searchBy = value;
        });
      },
      icon: Icon(Icons.arrow_drop_down_circle, color: Color(0xff06e2b3),),
    );
  }
}

