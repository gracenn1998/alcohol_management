import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DriverShowTrips extends StatefulWidget {
  const DriverShowTrips() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DriverShowTripsState();
  }
}

class _DriverShowTripsState extends State<DriverShowTrips> {
  String _selectedDriverID = null;
  String _selectedTripID = null;
  int _selectedFuction = 0;

//  if (_selectedJourneyID != null)
//  {
//    String id = _selectedJourneyID;
//    _selectedJourneyID = null;
//    return showInfoJourney(
//      jID = id,
//    );
//  }

//  if (_selectedFuction == 1)
//  {
//    return AddJourney();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Tất Cả Hành Trình',
            style: appBarTxTStyle,
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.only(right: 15.0),
              icon: Icon(Icons.search),
              color: Color(0xff06e2b3),
              onPressed: () {
                //Tim kiem hanh trinh
                debugPrint('Tim kiem hanh trinh');
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('journeys').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text('Loading...',
                      style:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
            } else
              return getListTripView(snapshots.data.documents);
          },
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.only(bottom: 1.0),
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                  child: Icon(Icons.filter_list),
                  tooltip: 'Lọc',
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xff8391b3),
                  onPressed: () => showDialog(context: context, builder: (context) => filterDialog())
              ),
              Container(padding: EdgeInsets.only(left: 2.5, right: 2.5),),
              FloatingActionButton(
                child: Icon(Icons.add),
                tooltip: 'Thêm hành trình',
                backgroundColor: Color(0xffef3964),
                foregroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    debugPrint('Add');
                    _selectedFuction = 1;
                  });
                },
              ),
            ],
          ),
        )
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
                          document[index].documentID,
                          style: const TextStyle(
                              color: const Color(0xff000000),
                              fontWeight: FontWeight.w900,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 28.0
                          ),
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
                              child: getStatusTrip(document[index].data['status']),
                            ),
                            flex: 2,
                          ),
//                          Expanded(
//                              flex: 1,
//                              child: Container(
//                                padding: EdgeInsets.only(top: 5.0),
//                                alignment: Alignment.topRight,
//                                child: IconButton(
//                                  icon: Icon(Icons.delete),
//                                  iconSize: 30.0,
//                                  color: Color(0xff0A2463),
//                                  onPressed: () {
//                                    //Xoa journey
//                                    debugPrint(
//                                        "Delete journey ${document[index].documentID} tapped");
//                                    confirmDelete(
//                                        context, document[index].documentID);
//                                  },
//                                ),
//                              ))
// Khong cho tai xe xoa hanh trinh
                        ],
                      ),
                    )
                  ],
                ),
                //

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
                                  formattedDate(document[index].data['schStart']),
                                  style: TextStyle(
                                      color: Color(0xff0a2463),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Roboto",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15.0)
                              ),
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
                            StreamBuilder<QuerySnapshot> (
                              stream:
                              Firestore.instance.collection('drivers').where('dID', isEqualTo: document[index].data['dID']).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
                                if(snapshots.hasError) {
                                  return Center(child: Text('Loading...', style: tempStyle,),);
                                }
                                else if (snapshots.data.documents.isEmpty) {
                                  return Container(
                                    constraints: BoxConstraints(maxWidth: 170),
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      'Không tìm được tài xế',
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
                                else
                                  return Container(
                                    constraints: BoxConstraints(maxWidth: 170),
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      snapshots.data.documents[0].data['name'].toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "Roboto",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 20.0
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                              },
                            )
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
                          child: Text(
                              "Từ:",
                              style: const TextStyle(
                                  color:  const Color(0xff8391b3),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle:  FontStyle.normal,
                                  fontSize: 14.0
                              )
                          )
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.only(left: 15.0, top: 10.0),
                          child: Text(
                              "Đến:",
                              style: const TextStyle(
                                  color:  const Color(0xff8391b3),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle:  FontStyle.normal,
                                  fontSize: 14.0
                              )
                          )
                      ),
                    ),
                  ],
                ), //3

                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, top: 1.0),
                        child:
                        Text(
                          document[index].data['from'],
                          style: TextStyle(
                              color:  Color(0xff000000),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Roboto",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 5.0, right: 15.0, top: 1.0),
                        child:
                        Text(
                          document[index].data['to'],
                          style: TextStyle(
                              color:  Color(0xff000000),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Roboto",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                        ),
                      ),
                    )
                  ],
                ), //4
              ],
            ),
          ),
          onTap: () {
            debugPrint("journey tapped");
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
            Firestore.instance.collection('journeys').document(id).delete();
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
        builder: (BuildContext context) => confirmDialog
    );
  }

  Text getStatusTrip(String data) {
    if (data == 'notStarted') return Text('Chưa bắt đầu', style: tripStatusStyle(1),);
    else if (data == 'working') return Text('Đang làm việc', style: tripStatusStyle(2),);
    else return Text('Đã hoàn thành', style: tripStatusStyle(0),);
  }
  String formattedDate(data) {
    final df = new DateFormat('dd/MM/yyyy');
    var formatted = df.format(data);
    return formatted;
  }
}

class filterDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _filterDialogState();
  }
}

class _filterDialogState extends State<filterDialog> {
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
              onChanged: (int val) => setState(() => _curentIndex = val)
          ),
          RadioListTile(
              title: Text('Đang làm việc'),
              value: 2,
              groupValue: _curentIndex,
              onChanged: (int val) => setState(() => _curentIndex = val)
          ),
          RadioListTile(
              title: Text('Chưa bắt đầu'),
              value: 3,
              groupValue: _curentIndex,
              onChanged: (int val) => setState(() => _curentIndex = val)
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            debugPrint('Lọc r show kq theo ${_curentIndex}');
            setState(() {
              DriverShowTrips();
            });
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

