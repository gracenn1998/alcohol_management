import 'package:alcohol_management/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ShowAllJourneys extends StatefulWidget {
  const ShowAllJourneys() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllJourneysState();
  }
}

class _showAllJourneysState extends State<ShowAllJourneys> {
  String _selectedJourneyID = null;
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
            return getListJourneyView(snapshots.data.documents);
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
                onPressed: () {
                  setState(() {
                    debugPrint('Lọc');
                  });
                },
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

  Widget getListJourneyView(document) {
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
                                  debugPrint(
                                      "Delete journey ${document[index].documentID} tapped");
                                  confirmDelete(
                                      context, document[index].documentID);
                                },
                              ),
                            ))
                        ],
                      ),
                    )
                  ],
                ),
                //1

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
                            Container(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text(
                                'Ten tai xe',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 20.0)
                              ),
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
//                            '154 Lý Tự Trọng, P. An Cư, Q. Ninh Kiều, TPCT',
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
//                            '12A Nguyễn Văn Cừ Nối Dài, P. An Lạc, Q. Ninh Kiều, TPCT',
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
      separatorBuilder: (context, idex) {
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
        builder: (BuildContext context) => confirmDialog);
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
