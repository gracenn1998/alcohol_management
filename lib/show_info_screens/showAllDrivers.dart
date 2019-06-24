import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import '../styles/styles.dart';
import "./showDriverInfoScreen.dart";
import "../add_screens/addDriverScreen.dart";

class ShowAllDrivers extends StatefulWidget {
  const ShowAllDrivers({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllDriversState();
  }
}

class _showAllDriversState extends State<ShowAllDrivers> {
  String _selectedDriverID = null;
  int _selectedFuntion = 0;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_selectedDriverID != null) {
      String id = _selectedDriverID;
      _selectedDriverID = null;
      return ShowDriverInfo(
        key: PageStorageKey("showInfo"),
        dID: id,
      );
    }

    if (_selectedFuntion == 1) {
      return AddDriver();
    }

    return Scaffold(
        appBar: AppBar(
//        leading: Icon(
//          Icons.dehaze,
//          color: Color(0xff06E2B3),
//        ),
            title: Center(child: Text("Tất Cả Tài Xế", style: appBarTxTStyle,),
            )),
        body: //getListDriversView(),
        StreamBuilder(
          stream: Firestore.instance.collection('drivers').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting)
              return Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              );
            else
              return getListDriversView(snapshots.data.documents);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint("Add Driver Request");
            setState(() {
              _selectedFuntion = 1;
            });
          },
          child: Icon(Icons.add),
          tooltip: "Thêm tài xế",
          backgroundColor: Color(0xff0A2463),
          foregroundColor: Colors.white,
        ));
  }

//  List<String> getListDrivers() {
//    var drivers = List<String>.generate(10, (counter) => "Tài xế $counter");
//    return drivers;
//  }

  Widget getListDriversView(document) {

//    var listDrivers = count;
    var listView = ListView.separated(
      itemCount: document.length,
      itemBuilder: (context, index) {

        int alcoholTrack = document[index]['alcohol-track'];
        String onWorking, alcoholVal;
        int status;
        if(alcoholTrack == null) {
          onWorking = 'Đang nghỉ';
          alcoholVal = 'Không hoạt động';
          status = -1;
        }
        else {
          if(alcoholTrack <= 350) {
            onWorking = 'Đang làm việc';
            alcoholVal = alcoholTrack.toString();
            status = 0;
          }
          else {
            onWorking = 'Say xỉn';
            alcoholVal = alcoholTrack.toString();
            status = 1;
          }
        }

        return InkWell(
          child: Container(
              height: 120.0,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: CircleAvatar(
                        radius: 45.0,
                        backgroundImage: AssetImage('images/avatar.png'),
                      )), // Avatar
                  Expanded(
                    flex: 4,
                    child: Container(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Text(document[index].data['name'],
                                  style: driverNameStyle()),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Trạng thái: ", style: driverStatusTitleStyle(status)),
                                  Text("$onWorking", style: driverStatusDataStyle(status)),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text("Chỉ số cồn: ", style: driverStatusTitleStyle(status)),
                                Text("$alcoholVal", style: driverStatusDataStyle(status)),
                              ],
                            ),
                          ],
                        )),
                  ), //Ten + Trang thai
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: IconButton(
                          padding: EdgeInsets.only(top: 22.0),
                          icon: Icon(Icons.delete),
                          iconSize: 30.0,
                          color: Color(0xff0A2463),
                          onPressed: () {
                            //Xoa driver
                            debugPrint("Delete driver ${document[index].documentID} tapped");
                            confirmDelete(context, document[index].documentID);
                          },
                        ),
                      )

                  ) //Nut xoa
                ],
              )),
          onTap: () {
            //go to detail info
            debugPrint("driver tapped");
            setState(() {
              _selectedDriverID = document[index].documentID;
            });
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1.0,
        );
      },
    );
    return listView;
  }

  void confirmDelete(BuildContext context, id) {
    var confirmDialog = AlertDialog(
      title: Text('Bạn muốn xóa tài xế này?'),
      content: null,
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Không'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Firestore.instance.collection('drivers').document(id).delete();
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
}