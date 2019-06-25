import 'package:flutter/material.dart';

class WorkingTripDetail extends StatefulWidget{
  final trip;
  const WorkingTripDetail({Key key, @required this.trip}) : super(key: key);
  State<WorkingTripDetail> createState() => WorkingTripDetailState(trip);

}

class WorkingTripDetailState extends State<WorkingTripDetail>{
  final trip;
  WorkingTripDetailState(this.trip);

  Widget build(BuildContext context){
    return Center(child: Text("Working"),);
  }

}