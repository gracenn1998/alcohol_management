import "package:flutter/material.dart";
import '../styles/styles.dart';
import "package:alcohol_management/show_info_screens/showDriverInfoScreen.dart";
import './showAllDrivers.dart';

class ShowAllDrivers extends StatefulWidget {
  const ShowAllDrivers() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllDriversState();
  }
}

class _showAllDriversState extends State<ShowAllDrivers> {
  String _selectedDriverID = null;




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_selectedDriverID!=null) {
      
      String id = _selectedDriverID;
      _selectedDriverID = null;
      return ShowDriverInfo(
        dID: id,
      );
    }


    return Scaffold(
        appBar: AppBar(
//          leading: Icon(
//            Icons.dehaze,
//            color: Color(0xff06E2B3),
//          ),
          title: Text(
            "Tất Cả Tài Xế",
            style: appBarTxTStyle,
          ),
          backgroundColor: Color(0xff0A2463),
        ),
        body: getListDriversView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint("Add Driver Request");
          },
          child: Icon(Icons.add),
          tooltip: "Thêm tài xế",
          backgroundColor: Color(0xff0A2463),
          foregroundColor: Colors.white,
        ));
  }

  List<String> getListDrivers() {
    var drivers = List<String>.generate(10, (counter) => "Tài xế $counter");
    return drivers;
  }

  Widget getListDriversView() {
    var listDrivers = getListDrivers();
    var listView = ListView.separated(
      itemCount: listDrivers.length,
      itemBuilder: (context, index) {
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
                              child: Text(listDrivers[index],
                                  style: driverNameStyle()),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Trạng thái: ",
                                      style: driverStatusTitleStyle(0)),
                                  Text("Bình thường",
                                      style: driverStatusDataStyle(0)),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text("Nồng độ cồn: ",
                                    style: driverStatusTitleStyle(0)),
                                Text("0.5%", style: driverStatusDataStyle(0)),
                              ],
                            ),
                          ],
                        )),
                  ), //Ten + Trang thai
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      iconSize: 40.0,
                      color: Color(0xff0A2463),
                      onPressed: () {
                        //Xoa driver
                        debugPrint("Delete driver tapped");
                        confirmDelete(context);
                      },
                    ),
                  ) //Nut xoa
                ],
              )),
          onTap: () {
            //go to detail info
            debugPrint("driver tapped");
            setState(() {
              _selectedDriverID = 'TX0001';
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

  void confirmDelete(BuildContext context) {
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
            //xoa thiet ._.
            Navigator.pop(context);
          },
          child: Text('Xóa', style: TextStyle(color: Colors.red),),
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

