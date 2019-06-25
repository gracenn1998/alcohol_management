import 'package:flutter/material.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

TextStyle TripID(){
  return TextStyle(
    fontSize: 28.0,
    fontFamily: "Rotobo",
    color: const Color(0xff000000),
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.normal,
  );
}

Widget showTripID(jID){
  return
    Container(
      padding: EdgeInsets.all(10.0),
      child: Text(
        jID,
        style: TripID(),
      ),
      color: Colors.white,
    );
}

String toStatusInVN(String x) {
  switch (x){
    case 'done':
      return "Đã hoàn thành";
    case 'notStarted':
      return "Chưa bắt đầu";
    case 'working':
      return "Đang đi???";
  }
  return null;
}

String formatDateTime(time) => DateFormat("dd/MM/yyyy").add_jm().format(time);

Widget getDriverNameByID(dID) {
  return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
       builder: (context, snapshot) {
        // print('acb');
         if(!snapshot.hasData)
        return showDetailItem("Tài xế", "Chưa phân công", 0, 'notStarted');
      var t = snapshot.data.documents[0];
      return showDetailItem("Tài xế", t['name'], 0, 'normal');
  });
}

Widget showDetails(trip, Tstatus) {
    String id = trip['jID'];
   // String driver = trip['dID'] == null? "Chưa phân công": trip['dID'];
    final schStart = formatDateTime(trip['schStart']);
    final start = trip['start'] == null? "Hành trình chưa bắt đầu": formatDateTime(trip['start']);
    final finish = trip['finish']== null? "Hành trình chưa bắt đầu": formatDateTime(trip['finish']);
    String from = trip['from'];
    String to = trip['to'];
    String status = toStatusInVN(trip['status']);

    return Container (
        margin: EdgeInsets.only( bottom: 15.0),
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showDetailItem('ID', id, 1, 'normal'),
     //           showDetailItem('Tài xế', driver, 0, (Tstatus == 'notStarted' && driver == null)?'notStarted':'normal'),
                getDriverNameByID(trip['dID']),
                showDetailItem('TG dự kiến', schStart, 1, 'normal'),
                showDetailItem('TG bắt đầu', start, 0, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('TG kết thúc', finish, 1, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('Từ', from, 0, 'normal'),
                showDetailItem('Đến', to, 1, 'normal'),
                showDetailItem('Trạng Thái', status, 0, Tstatus),
              ],
            )
        )
    );

  }

TextStyle tripDetailsStyle(status){
  switch (status){
    case 'normal':
      return driverInfoStyle();
    case 'done': //dahoanthanh
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xff00bc94),
      );
    case 'notStarted': //chuabatdau
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xffef3964),
      );
    case 'working': //chuabatdau
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xfff9aa33),
      ) ;
  }
}

Widget showDetailItem(title, data, line, status) {
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
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$data",
                style: tripDetailsStyle(status),
              ),
            ),
          ),
        ),
      ],

    );
  }
