import "package:flutter/material.dart";
import '../styles/styles.dart';
import "./showDriverInfoScreen.dart";
import "../add_screens/addDriverScreen.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        body: StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver').onValue,
          builder: (BuildContext context, snapshots) {
            if(!snapshots.hasData) {
              return Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                )
              );
            }
            else if(snapshots.hasData) {
              List<dynamic> driverList;

              DataSnapshot driverSnaps = snapshots.data.snapshot;
              Map<dynamic, dynamic> map = driverSnaps.value;
              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
//              for(var value in driverSnaps.value.values) {
//                if(!value['isDeleted']) { //show only drivers have not been deleted yet
//                  driverList.add(value);
//                }
//              }
              driverList = map.values.toList()..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));

              return getListDriversView(driverList);
            }
//            else if(snapshot.hasError) => return "Error";
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

  Widget getListDriversView(driverSnaps) {

    var listView = ListView.separated(
      itemCount: driverSnaps.length,
      itemBuilder: (context, index) {
        String onWorking, alcoholTrack;

        int status;
        String dID = driverSnaps[index]['dID'];
        var alcoholVal =  driverSnaps[index]['alcoholVal'];

        if(alcoholVal < 0) {
          onWorking = 'Đang nghỉ';
          alcoholTrack = 'Không hoạt động';
          status = -1;
        }
        else {
          if(alcoholVal <= 350) {
            onWorking = 'Đang làm việc';
            alcoholTrack = alcoholVal.toString();
            status = 0;
          }
          else {
            onWorking = 'Say xỉn';
            alcoholTrack = alcoholVal.toString();
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
                            child: Text(driverSnaps[index]['basicInfo']['name'],
                                style: driverNameStyle()),
                          ),
                          Column(
                            children: <Widget>[
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
                                  Text("$alcoholTrack", style: driverStatusDataStyle(status)),
                                ],
                              )
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
                            debugPrint("Delete driver ${dID} tapped");
                            confirmDelete(context, dID);
                          },
                        ),
                      )

                  ) //Nut xoa
                ],
              )),
          onTap: () {
            //go to detail info
            setState(() {
              _selectedDriverID = dID;
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
            FirebaseDatabase.instance.reference()
                .child('driver')
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
        builder: (BuildContext context) => confirmDialog
    );
  }
}