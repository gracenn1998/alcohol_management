import "package:flutter/material.dart";
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
  var drivers = List<String>.generate(5, (counter) => "Tài xế $counter");
  return drivers;
}

Widget getListDriversView() {
  var listDrivers = getListDrivers();
  var listView = ListView.separated(
    itemCount: listDrivers.length,
    itemBuilder: (context, index) {
      return
        ListTile(
          leading: Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            width: 50.0,
            height: 70.0,
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('images/ava.png'),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(listDrivers[index], style: driverNameStyle(),),
          ),
          subtitle: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: <Widget>[
                    Text('Trạng thái: ', style: driverStatusTitleStyle(),),
                    Text('Đang làm việc', style: driverStatusTitleStyle(),),
                  ],
                ),
              ),

              Row(
                children: <Widget>[
                  Text('Nồng dộ cồn: ', style: driverStatusTitleStyle(),),
                  Text('0.05%', style: driverStatusTitleStyle(),),
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.delete, size: 40.0, color: Color(0xff0A2463),),
          onTap: () {
            debugPrint("Show information of ${listDrivers[index]}");
            ShowDriverInfo(
              key: PageStorageKey('Page1'),
            );
          },
        );
    },
    separatorBuilder: (context, index) {
      return Divider(height: 1.0,);
    },
  );
  return listView;
}

TextStyle driverStatusTitleStyle() {
  return TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: Color(0xff8391b3),
  );
}

TextStyle driverNameStyle() {
  return TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}