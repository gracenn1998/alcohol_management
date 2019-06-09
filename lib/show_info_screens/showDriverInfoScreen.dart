import 'package:flutter/material.dart';
import '../styles/styles.dart';


class ShowDriverInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              //backkkk
            },
          ),
          title: Text('Thông tin tài xế', style: appBarTxTStyle(), textAlign: TextAlign.center,),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              //editttt
            },
          )
        ),
      ),
      body: showAllInfo(),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//
//        },
//        child: Icon(Icons.gps_fixed),
//        tooltip: 'Xác định vị trí xe đang ở',
//      ),

    );
  }
}

Widget showAllInfo() {
  return Column(
    children: <Widget>[
      Expanded(
        flex: 6,
        child: showBasicInfo('Trần Văn A', 'Đang làm việc', '0.5%'),
      ),
      Expanded(
        flex: 19,
        child: showDetails()
      ),
      Expanded(
        flex: 3,
        child: generatePasswordButton(),
      ),

    ],
  );
}

Widget showBasicInfo(name, status, alcohol) {
  return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 15.0),
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('images/avatar.png'),
              )
          ),
          Container(
              padding: EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text("$name", style: driverNameStyle()),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        Text("Trạng thái: ", style: driverStatusTitleStyle(0)),
                        Text("$status", style: driverStatusDataStyle(0)),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text("Nồng độ cồn: ", style: driverStatusTitleStyle(0)),
                      Text("$alcohol", style: driverStatusDataStyle(0)),
                    ],
                  ),
                ],
              )
          )

        ],
      )

  );
}

Widget showDetails() {
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            showDetailInfo('ID', 'TX0001', 1),
            showDetailInfo('Tuổi', '40', 0 ),
            showDetailInfo('CMND', '362412312', 1),
            showDetailInfo('Địa chỉ', '123 Lý Tự Trọng, Ninh Kiều, Cần Thơ, Việt Nam', 0),
            showDetailInfo('Email', 'tva0001@potatoes.driver.com', 1),
            showDetailInfo('Giới tính', 'Nam', 0 ),
            showDetailInfo('Ngày sinh', '01/01/1980', 1),
          ],
        )
      )
  );

}

Widget showDetailInfo(title, data, line) {
  return Row(
    children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
          height: 55.0,
//          margin: const EdgeInsets.all(5.0),
          padding: EdgeInsets.only(left: 25.0),
          decoration: line == 1 ? oddLineDetails() : evenLineDetails(), //             <--- BoxDecoration here
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$title",
              style: driverInfoStyle(),
            ),
          )
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          height: 55.0,
//          margin: const EdgeInsets.all(5.0),
          padding: EdgeInsets.only(left: 15.0),
          decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "$data",
                style: driverInfoStyle(),
              ),

          ),
        ),
      ),
    ],

  );
}


Widget generatePasswordButton() {
  return Container(
    color: Colors.white,
    margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),
    child: RaisedButton(
      child: Text(
          "Tạo mật khẩu mới",
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
          )
      ),
      elevation: 6.0,
      onPressed: () {
        //action
        debugPrint("New pw generated");
      },
    ),
  );
}

BoxDecoration myBoxDecorationOddLine() {
  return BoxDecoration(
    border: Border(
        left: BorderSide(
          color: Color(0xffDCDEE0),
          width: 1.0,
        )

    ),
    color: Color(0xffF3F4F6),
  );
}

BoxDecoration myBoxDecorationEvenLine() {
  return BoxDecoration(
    border: Border(
      left: BorderSide(
        color: Color(0xffDCDEE0),
        width: 1.0,
      )

    ),
    color: Colors.white

  );
}



