import 'package:alcohol_management/search_screens/searchTripScreen.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../show-trip-details/showTripDetails.dart';

class ShowTasks extends StatefulWidget {
  const ShowTasks({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showTasksState();
  }
}

class _showTasksState extends State<ShowTasks> {
  _showTasksState();

  String _selectedTripID = null;
  int _selectedFuction = 0;
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      _searching = false;
      return SearchTrip();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Tất Cả Hành Trình', style: appBarTxTStyle,),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.only(right: 15.0),
              icon: Icon(Icons.search),
              color: Color(0xff06e2b3),
              onPressed: () {
                debugPrint('Tim kiem hanh trinh');
                setState(() {
                  _searching = true;
                });
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('trips')
              .orderByChild('dID').equalTo('TX0003')
              .onValue,
          builder:(BuildContext context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                    style: tempStyle,
                  ));
            }
            else if(snapshots.hasData) {
              List<dynamic> tripList = [];

              DataSnapshot tripSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = tripSnaps.value;

              for(var tripItem in map.values) {
                if(!tripItem['isDeleted'] && tripItem['status']=='notStarted') {
                  tripList.add(tripItem);
                }
              }
              //sort by tID
              tripList..sort((a, b) => a['schStart'].compareTo(b['schStart']));
              return getListTripView(tripList);
            }

          },
        ),
    );
  }
  Widget getListTripView(document) {
    var listView = ListView.separated(
      itemCount: document.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, top: 5.0),
                        child: Text(
                          document[index]['tID'],
                          style: const TextStyle(
                              color: const Color(0xff000000),
                              fontWeight: FontWeight.w900,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 28.0),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child:
                              getStatusTrip(document[index]['status']),
                            ),
                            flex: 2,
                          ),
                        ],
                      ),
                    )
                  ],
                ), //1

                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, top: 5.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.event,
                              color: Color(0xff8391b3),
                              size: 23.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text(
                                  formattedDate(
                                      document[index]['schStart']),
                                  style: TextStyle(
                                      color: Color(0xff0a2463),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Roboto",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15.0)),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, top: 5.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.assignment_ind,
                              color: Color(0xff8391b3),
                              size: 23.0,
                            ),
                            document[index]['dID'] != null
                                ? StreamBuilder(
                              stream: FirebaseDatabase.instance.reference().child('driver')
                                  .orderByChild('dID').equalTo(document[index]['dID'])
                                  .onValue,
                              builder: (BuildContext context, snapshots) {
                                if (!snapshots.hasData) {
                                  return Center(
                                    child: Text(
                                      'Loading...',
                                      style: tempStyle,
                                    ),
                                  );
                                }
//                                else if (snapshots.data.documents.isEmpty) {
//                                  return Container(
////                                    constraints: BoxConstraints.tight(100.0),
//                                    padding: EdgeInsets.only(left: 5.0),
//                                    child: Text(
//                                      'Không có tài xế',
//                                      style: TextStyle(
//                                          color: Colors.black,
//                                          fontWeight: FontWeight.w700,
//                                          fontFamily: "Roboto",
//                                          fontStyle: FontStyle.normal,
//                                          fontSize: 20.0),
//                                      overflow: TextOverflow.ellipsis,
//                                    ),
//                                  );
//                                }
                                else {
                                  var dID = document[index]['dID'];
                                  var name = snapshots.data.snapshot.value[dID]['basicInfo']['name'];
                                  return Container(
                                    constraints: BoxConstraints(maxWidth: 170),
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "Roboto",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 20.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }

                              },
                            ): Container(
                                constraints: BoxConstraints(maxWidth: 170),
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text(
                                  "Chưa phân công",
                                  style: TextStyle(
                                      color: Color(0xffef3964),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Roboto",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 20.0),
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ), //2

                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.only(left: 15.0, top: 10.0),
                          child: Text("Từ:",
                              style: const TextStyle(
                                  color: const Color(0xff8391b3),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.only(left: 15.0, top: 10.0),
                          child: Text("Đến:",
                              style: const TextStyle(
                                  color: const Color(0xff8391b3),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0))),
                    ),
                  ],
                ), //3

                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, top: 1.0),
                        child: Text(
                          document[index]['from'],
                          style: TextStyle(
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 14.0),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding:
                        EdgeInsets.only(left: 5.0, right: 15.0, top: 1.0),
                        child: Text(
                          document[index]['to'],
                          style: TextStyle(
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 14.0),
                        ),
                      ),
                    )
                  ],
                ), //4
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowTripDetails(
                    key: PageStorageKey('showInfo'),
                    tID: document[index]['tID']))
            );
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
    return listView;
  }

  String formattedDate(data) {
    final df = new DateFormat('dd/MM/yyyy');
    var formatted = df.format(DateTime.fromMillisecondsSinceEpoch(data))
        .toString();
    return formatted;
  }

  Text getStatusTrip(String data) {
    if (data == 'notStarted')
      return Text(
        'Chưa bắt đầu',
        style: tripStatusStyle(1),
      );
    else if (data == 'working')
      return Text(
        'Đang làm việc',
        style: tripStatusStyle(2),
      );
    else
      return Text(
        'Đã hoàn thành',
        style: tripStatusStyle(0),
      );
  }
}

