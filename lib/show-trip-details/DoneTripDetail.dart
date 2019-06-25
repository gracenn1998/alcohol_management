import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'TripDetails-style-n-function.dart';

class DoneTripDetail extends StatefulWidget{
  final trip;
  const DoneTripDetail({Key key, @required this.trip}) : super(key: key);
  State<DoneTripDetail> createState() => DoneTripDetailState(trip);

}

class DoneTripDetailState extends State<DoneTripDetail>{
  final trip;
  DoneTripDetailState(this.trip);

  int _selectedIndex = 0;

  Widget build(BuildContext context){
    /*if(_selectedIndex == -1) {
      return ShowAllJourneys();
    }
    if(_selectedIndex == 1) {
      return EditJourney(
        jID: jID,
      );
    }*/

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
            buildDoneTripDetail(),
            buildLogBtn()
          ],
        )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget buildDoneTripDetail(){
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
}