//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:intl/intl.dart';
//import '../styles/styles.dart';
//import 'package:backdrop/backdrop.dart';
//import 'editJourney.dart';
//import 'WorkingJourneyDetail.dart';
//import '../styles/journeyDetailStyle.dart';
//
//String toStatusInVN(String x)
//{
//  switch (x){
//    case 'done':
//      return "Đã hoàn thành";
//    case 'notStarted':
//      return "Chưa bắt đầu";
//    case 'working':
//      return "Đang đi???";
//  }
//  return null;
//}
//
//class ShowJourneyDetail extends StatefulWidget {
//  final String jID;
//  const ShowJourneyDetail({Key key, @required this.jID}) : super(key: key);
//  State<ShowJourneyDetail> createState() => ShowJourneyDetailState(jID);
//}
//
//class ShowJourneyDetailState extends State<ShowJourneyDetail> //with SingleTickerProviderStateMixin
//    {
//  String jID;
//  ShowJourneyDetailState(this.jID);
//  static const TextStyle tempStyle = TextStyle(
//      fontSize: 30, fontWeight: FontWeight.bold
//  );
//
//  int _selectedIndex = 0;
//
//  Widget build(BuildContext context)
//  {
//    /*if(_selectedIndex == -1) {
//      return ShowAllJourneys();
//    }*/
//    if(_selectedIndex == 1) {
//      return EditJourney(
//        jID: jID,
//      );
//    }
//
//    return Scaffold(
//      appBar: AppBar(
//        elevation: 0.0,
//        leading: IconButton(
//          icon: Icon(Icons.arrow_back_ios),
//          color: Color(0xff06E2B3),
//          onPressed: () {
//            setState(() {
//              _selectedIndex--;
//            });
//          }, //BACKKKKK
//        ),
//        title:  Center(child: Text("Thông tin hành trình", style: appBarTxTStyle, textAlign: TextAlign.center,)),
//        actions: <Widget>[
//          Padding(
//            padding: EdgeInsets.only(right: 5.0),
//            child: IconButton(
//              icon: Icon(Icons.edit),
//              color: Color(0xff06E2B3),
//              onPressed: () {
//                setState(() {
//                  _selectedIndex = 1;
//                });
//              }, // EDITTTTTTTT
//            ),
//          ),
//        ],
//      ),
//      body: StreamBuilder(
//        stream: Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
//        builder: (context, snapshot) {
//          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
//          return _showJourneyDetail(snapshot.data.documents[0]);
//        },
//      ),
//      resizeToAvoidBottomPadding: false,
//      //journeyStatus == JourneyStatus.working? buildWorkingJourneyScreen() : buildDoneorNotStartedJourneyScreen(),
//    );
//  }
//
//  // ??????????
//  Widget showJourneyID() {
//    return Container(
//        height: 120.0,
//        color: Colors.white,
//        child:  Text(jID, style: tempStyle,)
//    );
//  }
//
//  Widget _showJourneyDetail(journey) {
//    return journey['status'] == 'working'?
//    buildWorkingJourneyScreen(journey) :
//    buildDoneAndNotStartedJourneyScreen(journey);
//  }
//
//  Widget showDetails(journey) {
//    //id, driver, schStart, start, finish, from, to, status
//    //final df = new DateFormat('dd/MM/yyyy');
//    //var formattedDOB = df.format(dob.toDate());
//    String id = jID;
//    String driver = journey['dID'];
//    final schStart = journey['schStart'];
//    final start = journey['start'] == null? "Hành trình chưa bắt đầu": journey['start'];
//    final finish = journey['finish']== null? "Hành trình chưa bắt đầu": journey['finish'];;
//    String from = journey['from'];
//    String to = journey['to'];
//    String status = toStatusInVN(journey['status']);
//
//    return Container (
//        margin: EdgeInsets.only( bottom: 15.0),
//        child: SingleChildScrollView(
//            child: Column(
//              children: <Widget>[
//                showDetailItem('ID', id, 1),
//                showDetailItem('Tài xế', driver, 0),
//                showDetailItem('TG dự kiến', schStart, 1),
//                showDetailItem('TG bắt đầu', start, 0),
//                showDetailItem('TG kết thúc', finish, 1 ),
//                showDetailItem('Từ', from, 0),
//                showDetailItem('Đến', to, 1 ),
//                showDetailItem('Trạng Thái', status, 0),
//              ],
//            )
//        )
//    );
//
//  }
//
//  Widget LogButton() {
//    return MaterialButton(
//      child: Text("LOG"),
//      onPressed: null,
//    );
//  }
//
//  Widget StartJourneyButton() {
//    return MaterialButton(
//      child: Text("BẮT ĐẦU HÀNH TRÌNH"),
//      onPressed: null, //CHUYEN SANG SCREEN WORKING
//    );
//  }
//
//  Widget showDetailItem(title, data, line) {
//    return Row(
//      children: <Widget>[
//        Expanded(
//          flex: 2,
//          child: Container(
//              height: 55.0,
////          margin: const EdgeInsets.all(5.0),
//              padding: EdgeInsets.only(left: 25.0),
//              decoration: line == 1 ? oddLineDetails() : evenLineDetails(), //             <--- BoxDecoration here
//              child: Align(
//                alignment: Alignment.centerLeft,
//                child: Text(
//                  "$title",
//                  style: driverInfoStyle(),
//
//                ),
//              )
//          ),
//        ),
//        Expanded(
//          flex: 5,
//          child: Container(
//            height: 55.0,
////          margin: const EdgeInsets.all(5.0),
//            padding: EdgeInsets.only(left: 15.0, right: 15.0),
//            decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
//            child: Align(
//              alignment: Alignment.centerLeft,
//              child: Text(
//                "$data",
//                style: title == 'Trạng Thái' ? journeyStatusStyle():driverInfoStyle(),
//              ),
//
//            ),
//          ),
//        ),
//      ],
//
//    );
//  }
//
//  Widget buildDoneAndNotStartedJourneyScreen(journey){
//    return Column(
//      // crossAxisAlignment: CrossAxisAlignment.stretch,
//      children: <Widget>[
//        showJourneyID(),
//        Expanded(
//            child: showDetails(journey)
//        ),
//      ],
//    );
//  }
//
//  Widget buildWorkingJourneyScreen(journey) {
//    return WorkingJourneyDetail();
//  }
//
//}
