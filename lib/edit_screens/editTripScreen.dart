import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditTrip extends StatefulWidget {
  final tID;
  const EditTrip({Key key, @required this.tID}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EditTripState(tID);
  }
}

class EditTripState extends State<EditTrip> {
  int _selectedIndex = 0;
  String tID;

  EditTripState(this.tID);
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _schController = TextEditingController();
  final _driverIDController = TextEditingController();
  var trip;

  void dispose() {
    // Clean up the controller when the Widget is disposed
    _fromController.dispose();
    _toController.dispose();
    _schController.dispose();
    _driverIDController.dispose();
    super.dispose();
  }

  Widget build(BuildContext bc)
  {
    if(_selectedIndex == -1) {
      return Center(
        child: Text("Detail Screen"),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            //backkkk
            setState(() {
              _selectedIndex--;
            });
          },
        ),
        title:  Center(child: Text('Chỉnh sửa hành trình', style: appBarTxTStyle, textAlign: TextAlign.center,)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.check, size: 30.0,),
              color: Color(0xff06E2B3),
              onPressed: () {
                //confirm edit
                var confirmed = 1;
                if(confirmed == 1) {
                  editDataDTB(trip);
                  Fluttertoast.showToast(msg: 'Đã thay đổi thông tin hành trình');
                  setState(() {
                    _selectedIndex--;
                  });
//                dispose();
                }

              },
            ),
          ),
        ],
      ),
      body:
      //    Center(child: Text('Loading'),),
      StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('trips').child(tID).onValue,
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          trip = snapshot.data.snapshot.value;
          _toController.text = trip['to'];
          _fromController.text = trip['from'];
          _driverIDController.text = trip['dID'];

//          final df = new DateFormat('dd/MM/yyyy hh:mm');
//          var formattedStartTime = df.parse(trip['schStart']);
//          _schController.text = formattedStartTime.toString();

          _schController.text = trip['schStart'].toString();

          return EditTripDetail(trip);
        },
      ),
      resizeToAvoidBottomPadding: false,
    );
  }




  Widget EditTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['tID']),
        editDetails(trip, 'notStarted')
      ],
    );
  }


  String formatDateTime(time) => DateFormat("dd/MM/yyyy").add_jm().format(time);


  Widget editDetails(trip, Tstatus) {
    String id = trip['tID'];
    // String driver = trip['dID'] == null? "Chưa phân công": trip['dID'];
    //DateTime sch = DateFormat("dd/MM/yyyy hh:mm").parse(trip['schStart']);

    final start = trip['start'] == null? "Hành trình chưa bắt đầu": formatDateTime(trip['start']);
    final finish = trip['finish']== null? "Hành trình chưa bắt đầu": formatDateTime(trip['finish']);
    String status = toStatusInVN(trip['status']);

    _schController.text = DateFormat('dd/MM/yyyy kk:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(
        int.parse(_schController.text)))
        .toString();

    return Container (
        margin: EdgeInsets.only( bottom: 15.0),
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showDetailItem('ID', id, 1, 'normal'),
                editDetailItem("Mã tài xế", _driverIDController, 0, 'normal'),
                editDetailItem('Từ', _fromController, 1, 'normal'),
                editDetailItem('Đến', _toController, 0, 'normal'),
                editDetailItem('TG dự kiến', _schController, 1, 'normal'),
                showDetailItem('TG bắt đầu', start, 0, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('TG kết thúc', finish, 1, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('Trạng Thái', status, 0, Tstatus),
              ],
            )
        )
    );

  }



  Widget editDetailItem(title, controller, line, status) {
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
              child:
              TextFormField(
                controller: controller,
                style: driverInfoStyle(),
              ),
              /*Text(
                "$data",
                style: tripDetailsStyle(status),
              ),*/
            ),
          ),
        ),
      ],

    );
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



  void editDataDTB(trip) {
    var schMilli = DateFormat('dd/MM/yyyy kk:mm').parse(_schController.text).millisecondsSinceEpoch;
    schMilli+=3600000; //no idea :(

    FirebaseDatabase.instance.reference()
        .child('trips')
        .child(tID)
        .update({
      'from': _fromController.text,
      'to': _toController.text,
      'dID': _driverIDController.text,
      'schStart': schMilli,
    });

    //need transaction?


//    Firestore.instance.runTransaction((transaction) async{
////      DocumentSnapshot freshSnap =
////      await transaction.get(trip.reference);
////      print("ABC: ");
////      print(trip.reference);
//      await transaction.update(Firestore.instance.collection("journeys").document(tID), {
//        'from': _fromController.text,
//        'to': _toController.text,
//        'dID': _driverIDController.text,
//        'schStart': sch
//      });
//    });
  }



  Widget showTripID(tID){
    return
      Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          tID,
          style: TripID(),
        ),
        color: Colors.white,
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

  TextStyle TripID(){
    return TextStyle(
      fontSize: 28.0,
      fontFamily: "Rotobo",
      color: const Color(0xff000000),
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,
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

}