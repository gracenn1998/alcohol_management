/*
import 'package:flutter/material.dart';
import 'TripDetails-style-n-function.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_database/firebase_database.dart';
import '../styles/styles.dart';

class WorkingTripDetail_NV extends StatefulWidget{
  final jID;
  const WorkingTripDetail_NV({Key key, @required this.jID}) : super(key: key);
  State<WorkingTripDetail_NV> createState() => WorkingTripDetail_NVState(jID);

}


class WorkingTripDetail_NVState extends State<WorkingTripDetail_NV> with SingleTickerProviderStateMixin{
  final jID;
  var _trip, _driver;
  WorkingTripDetail_NVState(this.jID);

  PermissionStatus _status;
  AnimationController _animationController;
  int _selectedIndex = 0;

  static double JourneyInfoHeight = 190.0;
  // Can tim cach tinh chieu cao cua JourneyInfo() widget =.="
  //////////GET USER LOCATION
  Map<String, double> curLocation;

  Completer<GoogleMapController> _controller = Completer();
  //GoogleMapController _controller; //= Completer();
  Set<Marker>  allMarkers= {};
  Set<Polyline>_allPolylines={};



  Widget buildMap(){
    //  while(_driver == null);

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
      CameraPosition(
        target:
        _driver == null ?
        LatLng(10.03711, 105.78825): //Can Tho City
        LatLng(_driver['lat'], _driver['lng']), //driver location
        zoom: 15,
      ),
      markers: allMarkers,
      onMapCreated: (GoogleMapController controller) {
        allMarkers.clear();
        addToList(_trip);
        _controller.complete(controller);
      },
      myLocationEnabled : true,
    );
  }




//////////------------------------------------------------------

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        _trip = snapshot.data.documents[0];
        return buildWorkingTripScreen();
      },
    );
  }

  Widget buildWorkingTripScreen(){
    _askPermission();
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Center(child: Text("Thông tin hành trình") ,),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xff06E2B3),
          onPressed: () {
            setState(() {
              _selectedIndex--;
            });
          }, //BACKKKKK
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: new IconButton(
              onPressed: () {
                _animationController.fling(velocity: _isPanelVisible ? -1.0 : 0.5);
              },
              icon: new AnimatedIcon(
                color: Color(0xff06E2B3),
                icon: AnimatedIcons.close_menu,
                progress: _animationController.view,
              ),
            ),
          ),
        ],
      ),
      body:
      new LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> animation = _getPanelAnimation(constraints);

    return new Column(
      children: <Widget>[
        DriverInfo_NV(_trip),
        new Stack(
          children: <Widget>[
            new Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(
                  height: constraints.biggest.height - 120
              ),
            ),
            JourneyInfo(_trip),
            new PositionedTransition(
              rect: animation,
              child: new Material(
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(16.0),
                    topRight: const Radius.circular(16.0)),
                elevation: 12.0,
                child: new Column(children: <Widget>[
                  new Expanded(
                      child:
                      buildMap()
                  ),
                ]),
              ),
            )
          ],
        ),
      ],
    );
  }



  void initState(){

    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);

    PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);
  }

  //ANIMATIONNNNNNNNNNNNNNNNN
  bool get _isPanelVisible {
    final AnimationStatus status = _animationController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  Animation<RelativeRect> _getPanelAnimation(BoxConstraints constraints) {

    final double height = constraints.biggest.height - 200 ;
    print(height);
    print(JourneyInfoHeight);
    final double top = height - JourneyInfoHeight;//_PANEL_HEADER_HEIGHT ;
    final double bottom =  -JourneyInfoHeight;//_PANEL_HEADER_HEIGHT ;
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  //LOCATION ACCESS PERMISSIONNNNNNNNNN
  void _updateStatus(PermissionStatus status){
    //print("$status");
    if (status != _status)
    {
      setState(() {
        _status = status;
      });
    }
  }

  void _askPermission(){
    PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse])
        .then(_onStatusRequested);
  }

  void _onStatusRequested(Map <PermissionGroup, PermissionStatus> statuses ){
    final status = statuses[PermissionGroup.locationWhenInUse];

    if(status != PermissionStatus.granted)
      PermissionHandler().openAppSettings();

    _updateStatus(status);
  }

  //markers
  addToList(trip) async {
    final from = trip["from"];
    var addresses = await Geocoder.local.findAddressesFromQuery(from);
    var first = addresses.first;

    final to = trip["to"];
    var toAddresses = await Geocoder.local.findAddressesFromQuery(to);
    var toCoor = toAddresses.first;

    setState(() {
      allMarkers.add(new Marker(
        markerId: MarkerId('from') ,
        draggable: false,
        position  : new LatLng(
            first.coordinates.latitude, first.coordinates.longitude),

      )
      );
      //  print("Add r-------------------------------------------------------------------");
      allMarkers.add(new Marker(
        markerId: MarkerId('to') ,
        draggable: false,
        position  : new LatLng(
            toCoor.coordinates.latitude, toCoor.coordinates.longitude),
      )
      );

      allMarkers.add(
          new Marker(markerId: MarkerId('driverLocation'),
              position: new LatLng(_driver['lat'], _driver['lng']),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          )

      );
      print("Add r2 -------------------------------------------------------------------");
      print(allMarkers.last.position);
    });
  }



  Widget DriverInfo_NV(_trip){
    return Container(
        height: 120.0,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 15.0),
                child: CircleAvatar(
                  radius: 45.0,
                  backgroundImage: AssetImage('images/avatar.png'),
                )), // Avatar

            Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(_trip['name'],
                          style: driverNameStyleinJD()),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Chỉ số cồn ",
                          style: timeStyleinJD()),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        children: <Widget>[
                          Text("Ban đầu: ",
                              style: driverStatusTitleStyle(0)),
                          Text("100",
                              style: driverStatusDataStyle(0)),
                        ],
                      ),
                    ),

                    StreamBuilder(
                        stream: FirebaseDatabase.instance.reference().child('driver')
                            .child(_trip['dID']).onValue,
                        builder: (BuildContext context, snapshot) {
                          if(!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          else if(snapshot.hasData) {
                            _driver = snapshot.data.snapshot.value;
                            var alcoholVal = _driver['alcoholVal'];
                            print(_driver);
                            return  Row(
                              children: <Widget>[
                                Text("Hiện tại: ",
                                    style: driverStatusTitleStyle(0)),
                                Text(alcoholVal.toString(), style:alcoholVal>=350? driverStatusDataStyle(1) : driverStatusDataStyle(0)),
                              ],
                            );
                          }}
                    ),


                  ],
                )),
            //Ten + Trang thai
            Expanded(

              //padding: EdgeInsets.only(left: 5.0),
              child: Container(
                child: RaisedButton(
                  child: Text("XỬ LÝ", style: TextStyle(color: Colors.white),),
                  color: Color(0xffef3964),
                  onPressed: () {

                    print("XULYYYYYYYYyyy");
                    //  heightOfJourneyInfo();
                    //   print(JourneyInfoHeight);
                    //
//                      final RenderBox renderBoxRed = _keyRed.currentContext.findRenderObject();
//                      final sizeRed = renderBoxRed.size;
//                      print("SIZE of Red: ${sizeRed.height} ");
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 30.0),
            )
          ],
        )
    );
  }

}*/
