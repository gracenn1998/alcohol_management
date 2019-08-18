import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'showAllJourneys.dart';

class SearchTrip extends StatefulWidget {
  const SearchTrip() : super();

  @override
  State<StatefulWidget> createState() {
    return _searchTripState();
  }
}

class _searchTripState extends State<SearchTrip> {
  Icon icon = Icon(Icons.search);
  Widget appBarTittle = Text(
    'Tìm kiếm Hành Trình',
    style: appBarTxTStyle,
  );
  TextEditingController _controller = new TextEditingController();
  String _searchText = '';
  bool _searching = true;
  List<dynamic> _testList;
  List searchResults = new List();
  var queryResultSet = [];
  var tmpSearchStore = [];

  _searchTripState() {
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
      return ShowAllTrips(filterState: 0,);
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
            ? StreamBuilder(
          stream: Firestore.instance.collection('journeys')
                    .orderBy('jID')
                    .startAt([_controller.text]).endAt([_controller.text + '\uf8ff'])
                    .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)));
            } else return getListSearchView(snapshots.data.documents);
          },
        )
          : StreamBuilder(
            stream: Firestore.instance.collection('journeys').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text('Loading...',
                style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold)));
              } else return getListSearchView(snapshots.data.documents);
            },
          ));
  }

  Widget getListSearchView(List<DocumentSnapshot> documents) {
    return ListView.separated(
      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        debugPrint('${searchResults.length} in body');
        String jID = documents[index].documentID;
        return InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
              child: Text(
                jID,
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
}

