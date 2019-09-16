import 'package:alcohol_management/search_screens/searchTripScreen.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../show-trip-details/showTripDetails.dart';
import '../add_screens/addTripScreen.dart';

class ShowAllTrips extends StatefulWidget {
  final filterState;
  const ShowAllTrips({Key key, @required this.filterState}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllTripsState(filterState);
  }
}

class _showAllTripsState extends State<ShowAllTrips> {
  int filterState;
  _showAllTripsState(this.filterState);

  String _selectedTripID = null;
  int _selectedFuction = 0;
  bool _searching = false;

//  if (_selectedTripID != null)
//  {
//    String id = _selectedTripID;
//    _selectedTripID = null;
//    return showInfoTrip(
//      jID = id,
//    );
//  }

//  if (_selectedFuction == 1)
//  {
//    return AddTrip();
//  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      _searching = false;
      return SearchTrip();
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back), 
              color: (filterState > 0) ? Color(0xff06e2b3) : Color(0xff0A2463),
              onPressed: () {
                debugPrint('back');
//                if (filterState > 0) Navigator.pop(context);
                if (filterState > 0) setState(() {
                  filterState = 0;
                });
          }),
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
        body: display(filterState),
        floatingActionButton: Container(
          padding: EdgeInsets.only(bottom: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: 'filter_trip',
                  child: Icon(Icons.filter_list),
                  tooltip: 'Lọc',
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xff8391b3),
                  onPressed: () => showDialog(
                      context: context, builder: (context) => filterDialog())),
              Container(
                padding: EdgeInsets.only(left: 2.5, right: 2.5),
              ),
              FloatingActionButton(
                heroTag: 'add_trip',
                child: Icon(Icons.add),
                tooltip: 'Thêm hành trình',
                backgroundColor: Color(0xffef3964),
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTrip())
                  );
                },
              ),
            ],
          ),
        ));
  }

  Widget display(int filter) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('trips')
          .orderByChild('isDeleted').equalTo(false)
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



          switch (filter) {
            case 0:
              for(var tripItem in map.values) {
                if(!tripItem['isDeleted']) {
                  tripList.add(tripItem);
                }
              }
              break;
            case 1: //done
              for(var tripItem in map.values) {
                if(tripItem['status'] == 'done' && !tripItem['isDeleted']) {
                  tripList.add(tripItem);
                }
              }
              break;
            case 2: //working
              for(var tripItem in map.values) {
                if(tripItem['status'] == 'working' && !tripItem['isDeleted']) {
                  tripList.add(tripItem);
                }
              }
              break;
            case 3: //notStarted
              for(var tripItem in map.values) {
                if(tripItem['status'] == 'notStarted' && !tripItem['isDeleted']) {
                  tripList.add(tripItem);
                }
              }
              break;
          }
          //sort by tID
          tripList..sort((a, b) => b['tID'].compareTo(a['tID']));
          return getListTripView(tripList);
        }

      },
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
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(top: 5.0),
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                iconSize: 30.0,
                                color: Color(0xff0A2463),
                                onPressed: () {
                                  //Xoa journey
                                  debugPrint("Delete journey ${document[index]['tID']} tapped");
                                  confirmDelete(context, document[index]['tID']);
                                },
                              ),
                            ))
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

  void confirmDelete(BuildContext context, id) {
    var confirmDialog = AlertDialog(
      title: Text('Bạn muốn xóa hành trình này?'),
      content: null,
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Không'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            FirebaseDatabase.instance.reference()
                .child('trips')
                .child(id)
                .update({
              'isDeleted': true
            });
            Fluttertoast.showToast(msg: 'Đã xóa tài xế');
          },
          child: Text(
            'Xóa',
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => confirmDialog);
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

class filterDialog extends StatefulWidget {
  const filterDialog({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _filterDialogState();
  }
}

class _filterDialogState extends State<filterDialog> {
  _filterDialogState();
  int _curentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Text('Lọc'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Trạng thái"),
          RadioListTile(
              title: Text('Đã hoàn thành'),
              value: 1,
              groupValue: _curentIndex,
              onChanged: (int val) => setState(() => _curentIndex = val)),
          RadioListTile(
              title: Text('Đang làm việc'),
              value: 2,
              groupValue: _curentIndex,
              onChanged: (int val) => setState(() => _curentIndex = val)),
          RadioListTile(
              title: Text('Chưa bắt đầu'),
              value: 3,
              groupValue: _curentIndex,
              onChanged: (int val) => setState(() => _curentIndex = val)),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        FlatButton(
          onPressed: () {
            debugPrint('Lọc r show kq theo ${_curentIndex}');
            Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => ShowAllTrips(filterState: _curentIndex,)));
          },
          child: Text(
            'Xong',
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }
}

