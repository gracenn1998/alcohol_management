import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DoneTripDetail.dart';
import 'WorkingTripDetail.dart';
import 'NotStartedTripDetail.dart';

class ShowTripDetails extends StatefulWidget{
  final String jID;
  const ShowTripDetails({Key key, @required this.jID}) : super(key: key);
  State<ShowTripDetails> createState() => ShowTripDetailsState(jID);
}

class ShowTripDetailsState extends State<ShowTripDetails>{
  final String jID;
  ShowTripDetailsState(this.jID);

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
        return DoneTripDetail(trip: trip);
      case 'notStarted':
        return NotStartedTripDetail(trip: trip);
      case 'working':
        return WorkingTripDetail(trip: trip);

    }
  }

}

