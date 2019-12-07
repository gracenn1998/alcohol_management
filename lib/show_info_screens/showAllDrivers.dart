import 'package:alcohol_management/search_screens/searchDriver.dart';
import "package:flutter/material.dart";
import '../styles/styles.dart';
import "./showDriverInfoScreen.dart";
import "../add_screens/addDriverScreen.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ShowAllDrivers extends StatefulWidget {
  const ShowAllDrivers({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllDriversState();
  }
}

class _showAllDriversState extends State<ShowAllDrivers> {

  List avatarUrlList = new List();
  var isGetURLFinished = false;
  getImageUrl(driverList) async {
    var ref, url;
    for(int i = 0; i< driverList.length; i++){
      ref = FirebaseStorage.instance.ref().child(driverList[i]['dID']);
      try {
        url = await ref.getDownloadURL();
      }
      catch (error) {
        url = null;
      }
      avatarUrlList.add(url);
    }
    if(!isGetURLFinished) {

      setState(() {
        isGetURLFinished = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(null)
          ),
          title: Center(child: Text("Tất Cả Tài Xế", style: appBarTxTStyle,),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Color(0xff06e2b3),),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchDriver())
                );
              },
            )
          ],
        ),
        body:
        StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver')
              .orderByChild('isDeleted').equalTo(false)
              .onValue,
          builder: (BuildContext context, snapshots) {
            if(!snapshots.hasData) {
              return LoadingState;
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
              getImageUrl(driverList);
              return getListDriversView(driverList);
            }
//            else if(snapshot.hasError) => return "Error";
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint("Add Driver Request");
//            setState(() {
//              _selectedFuntion = 1;
//            });
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddDriver()));
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
        String name = driverSnaps[index]['basicInfo']['name'];
        String url;
        if(avatarUrlList.length>0) {
//          print('index: ' + index.toString());
          url = avatarUrlList[index];
        }
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
//        final ref = FirebaseStorage.instance.ref().child(dID);
//        print(dID);
//        print('ref: ' + ref.toString());
//        ref.getDownloadURL().then((result) {
//          url = result;
//          print("URL:" + url);
//
////          setState(() {
////            print("URL:" + url);
////            url = url;
////          });
//        }).catchError((error) {
////          print(error);
//        });

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
                      //backgroundColor: Colors.blue,
                      backgroundImage: AssetImage('images/avatar.png'),
                      child: ClipOval(
                          child:
                          SizedBox(
                              height: 100.0,
                              width: 100.0,
                              child:  (url != null)?
                              Image.network(
                                //"https://thumbs.gfycat.com/HastyResponsibleLeopard-mobile.jpg",
                                  url,
                                  fit: BoxFit.cover
                              ): SizedBox(
                                height: 100.0,
                                width: 100.0,

                              )
                          )
                      ),
                    )), // Avatar
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
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
                            confirmDelete(context, dID, name);
                          },
                        ),
                      )

                  ) //Nut xoa
                ],
              )),
          onTap: () {
            final page =  ShowDriverInfo(
                key: PageStorageKey('showInfo'),
                dID: dID
            );
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page)
            );
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

  void confirmDelete(BuildContext context, id, name) {
    var confirmDialog = AlertDialog(
      title: Text('Bạn muốn xóa tài xế $name ($id)?'),
      content: null,
      actions: <Widget>[
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
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Không'),
        ),
      ],
    );

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => confirmDialog
    );
  }
}