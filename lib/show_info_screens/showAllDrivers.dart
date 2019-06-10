import "package:flutter/material.dart";
import '../styles/styles.dart';
import "package:alcohol_management/ava.dart";
import "package:alcohol_management/show_info_screens/showDriverInfoScreen.dart";

class ShowAllDrivers extends StatelessWidget {
  const ShowAllDrivers() : super();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Tất Cả Tài Xế"),
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
        )
    );
  }
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
      return
        InkWell(
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
                      )
                  ),

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
                              child: Text(listDrivers[index], style: driverNameStyle()),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: <Widget>[
                                  Text("Trạng thái: ", style: driverStatusTitleStyle(0)),
                                  Text("Bình thường", style: driverStatusDataStyle(0)),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text("Nồng độ cồn: ", style: driverStatusTitleStyle(0)),
                                Text("0.5%", style: driverStatusDataStyle(0)),
                              ],
                            ),
                          ],
                        )
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(Icons.delete, size: 40.0, color: Color(0xff0A2463),),
                  )





                ],
              )

          ),
          onTap: () {
            //go to detail info
            debugPrint("driver tapped");
          },
        )
        ;

    },
    separatorBuilder: (context, index) {
      return Divider(height: 1.0,);
    },
  );
  return listView;
}

