import 'package:flutter/material.dart';

class NotStartedTripDetail extends StatefulWidget{
  final trip;
  const NotStartedTripDetail({Key key, @required this.trip}) : super(key: key);
  State<NotStartedTripDetail> createState() => NotStartedTripDetailState(trip);

}

class NotStartedTripDetailState extends State<NotStartedTripDetail>{
  final trip;
  NotStartedTripDetailState(this.trip);

  Widget build(BuildContext context){
    return Center(child: Text("Notstarted"),);
  }

}