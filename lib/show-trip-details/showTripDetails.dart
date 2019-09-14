import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WorkingTripDetail.dart';
import 'TripDetails-style-n-function.dart';
import '../styles/styles.dart';
import 'WorkingTripDetail_NV.dart';

class ShowTripDetails extends StatefulWidget{
  final String jID;
  const ShowTripDetails({Key key, @required this.jID}) : super(key: key);
  State<ShowTripDetails> createState() => ShowTripDetailsState(jID);
}

class ShowTripDetailsState extends State<ShowTripDetails>{
  final String jID;
  ShowTripDetailsState(this.jID);
  int _selectedIndex = 0;
  /*if(_selectedIndex == -1) {
      return ShowAllJourneys();
    }
    if(_selectedIndex == 1) {
      return EditJourney(
        jID: jID,
      );
    }*/

  Widget build(BuildContext context){
    return StreamBuilder(
      stream: Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return directTripDetailScreen(snapshot.data.documents[0]);
      },
    );
  }

  Widget directTripDetailScreen(trip){
    switch (trip['status']){
      case 'done':
        return DoneTripDetail(trip);
      case 'notStarted':
        return NotStartedTripDetail(trip);
      case 'working':
        return WorkingTripDetail(jID: jID);

    }
  }

//------------------------------------------------------
  Widget DoneTripDetail(trip){
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            setState(() {
              _selectedIndex--;
            });
          }, //BACKKKKK
        ),
        title:  Center(child: Text("Thông tin hành trình", style: appBarTxTStyle, textAlign: TextAlign.center,)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.edit),
              color: Color(0xff06E2B3),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              }, // EDITTTTTTTT
            ),
          ),
        ],
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              buildDoneTripDetail(trip),
              buildLogBtn()
            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );

  }

  Widget buildDoneTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['jID']),
        showDetails(trip, 'done')
      ],
    );
  }

  Widget buildLogBtn(){
    return Container(
      color: Color(0xff0a2463) ,
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: FlatButton(
        child: Text('LOG', style: TextStyle(color: Colors.white, fontSize: 18),),
        onPressed: (){
          print("LOG Button tapped");
        },
      ),
    );
  }
  //--------------------------------------------------------

  Widget NotStartedTripDetail(trip){
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            setState(() {
              _selectedIndex--;
            });
          }, //BACKKKKK
        ),
        title:  Center(child: Text("Thông tin hành trình", style: appBarTxTStyle, textAlign: TextAlign.center,)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.edit),
              color: Color(0xff06E2B3),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              }, // EDITTTTTTTT
            ),
          ),
        ],
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              buildNotStartedTripDetail(trip),
              buildStartBtn(),
            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }



  Widget buildNotStartedTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['jID']),
        showDetails(trip, 'notStarted')
      ],
    );
  }

  Widget buildStartBtn(){
    return Container(
      color: Color(0xff0a2463) ,
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: FlatButton(
        child: Text('BẮT ĐẦU HÀNH TRÌNH', style: TextStyle(color: Colors.white, fontSize: 18),),
        onPressed: (){
          print("Start button tapped");
          assignDialog();
        },
      ),
    );
  }



  void assignDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}



