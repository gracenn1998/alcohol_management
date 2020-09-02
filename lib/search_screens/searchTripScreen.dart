import 'package:alcohol_management/show_info_screens/showAllTrips.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../show-trip-details/showTripDetails.dart';

class SearchTrip extends StatefulWidget {
  final filter;
  const SearchTrip({Key key, @required this.filter}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _searchTripState(filter);
  }
}

class _searchTripState extends State<SearchTrip> {
  int filter;
  Icon icon = Icon(Icons.search);
  Widget appBarTittle = Text('Tìm kiếm Hành Trình', style: appBarTxTStyle);
  TextEditingController _controller = new TextEditingController();
  List searchResults = new List();
  var queryResultSet = [];
  var tmpSearchStore = [];

  _searchTripState(this.filter) {
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    List<dynamic> tripList;

    List<dynamic> searchWithKeyWord(String keyword) {
      List<dynamic> searchResult = new List<dynamic>();
      keyword = keyword.toLowerCase();
      String from, to, did, driverName, vid;
      for(int i = 0; i < tripList.length; i++) {
//        driverName = tripList[i]['basicInfo']['name'].toString().toLowerCase();
        did = tripList[i]['dID'].toString().toLowerCase();
        vid = tripList[i]['vID'].toString().toLowerCase();
        from = tripList[i]['from'].toString().toLowerCase();
        to = tripList[i]['to'].toString().toLowerCase();

        if(from.contains(keyword)
            || to.contains(keyword)
            || did.contains(keyword)
            || vid.contains(keyword)) {
          searchResult.add(tripList[i]);
        }
      }
      return searchResult;
    }

    String status = "all";
    switch (filter) {
      case 1:
        status = "done";
        break;
      case 2:
        status = "working";
        break;
      case 3:
        status = "notStarted";
        break;
    }


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xff06e2b3),
          ),
          onPressed: () {
            Navigator.of(context).pop();
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
      ),
//      buildBar(context),
      body: _controller.text.isNotEmpty
            ?
          StreamBuilder(
            stream: status=="all"?
              FirebaseDatabase.instance.reference().child('trips')
                  .onValue
            :
              FirebaseDatabase.instance.reference().child('trips')
                  .orderByChild('status').equalTo(status)
                  .onValue,
            builder: (BuildContext context, AsyncSnapshot snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
              else {
                DataSnapshot tripSnaps = snapshots.data.snapshot;
                Map<dynamic, dynamic> map = tripSnaps.value;
                if (map != null) {
                  tripList = map.values.toList();
                  for (int i=0; i<tripList.length; ++i) {
                    if (tripList[i]['isDeleted'])
                      tripList.removeAt(i);
                  }
                }
                return getListSearchView(searchWithKeyWord(_controller.text));
              }
            },
          )
          :
      StreamBuilder(
        stream: status=="all"?
              FirebaseDatabase.instance.reference().child('trips')
                  .onValue
            :
              FirebaseDatabase.instance.reference().child('trips')
                  .orderByChild('status').equalTo(status)
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
            final page =  ShowTripDetails(
                key: PageStorageKey('showInfo'),
                tID: tID
            );
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page)
            );
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

}

