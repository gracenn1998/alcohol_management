import 'package:flutter/material.dart';
import 'TripDetails-style-n-function.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_database/firebase_database.dart';

class WorkingTripDetail_NV extends StatefulWidget{
  final jID;
  const WorkingTripDetail_NV({Key key, @required this.jID}) : super(key: key);
  State<WorkingTripDetail_NV> createState() => WorkingTripDetail_NVState(jID);

}


class WorkingTripDetail_NVState extends State<WorkingTripDetail_NV> with SingleTickerProviderStateMixin{
  final jID;
  var _trip;
  WorkingTripDetail_NVState(this.jID);

  PermissionStatus _status;
  AnimationController _animationController;
  int _selectedIndex = 0;

  static double JourneyInfoHeight = 190.0;
  // Can tim cach tinh chieu cao cua JourneyInfo() widget =.="
  //////////GET USER LOCATION
  Map<String, double> curLocation;

  //Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController; //= Completer();
  Set<Marker>  allMarkers = {};

  Set<Marker> modifyMarker(double Lat, double Lng){
  //  Markers.clear();
    allMarkers.removeWhere((Marker a){ return a.markerId == MarkerId('DriverCurLocation'); });
    Marker driverMarker =
      new Marker(
          markerId: MarkerId('DriverCurLocation'),
          draggable: false,
          position: new LatLng(Lat, Lng)
      )
    ;
    allMarkers.add(driverMarker);
    print("MODIFYYYYYYYYYYYYYYYYY MARKER CALLLLLLLLLLLLLL");
//    print(allMarkers);
//    print("MODIFYYYYYYYYYYYYYYYYY MARKER CALLLLLLLLLLLLLL222222222222");
       return allMarkers;
  }

  Widget buildMap(driver){

    print("buildMap: $driver");
    print("buildMap: $allMarkers");

    return new GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
      CameraPosition(
        target:
        driver == null ?
        LatLng(10.03711, 105.78825): //Can Tho City
        LatLng(driver['lat'], driver['lng']), //user location
        //  LatLng(10.03711, 105.78825),
        zoom: 15,
      ),
      markers: modifyMarker(driver['lat'], driver['lng']),
      onMapCreated: (GoogleMapController controller) async {
        allMarkers.clear();
        await addToList(_trip);
        print("Create mappppppppppppppppppppppp");
        print(allMarkers);
        mapController = controller;
        //_controller.complete(controller);
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
        print("Build func: streambuilder on Firestore_______________________________");

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
        DriverInfo(_trip),
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
                    StreamBuilder(
                      stream: FirebaseDatabase.instance.reference()
                          .child('driver').child(_trip['dID']).onValue,
                      builder: (BuildContext context, snapshot){
                        if(!snapshot.hasData)
                        {
                          return Center(child: CircularProgressIndicator());
                        }
                        else if(snapshot.hasData){
                          var driver = snapshot.data.snapshot.value;
                          print("_buildStack: Listen on driver location changed: $driver");
                          return buildMap(driver);
                        }
                      },

                    ),
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


    });
  }



}