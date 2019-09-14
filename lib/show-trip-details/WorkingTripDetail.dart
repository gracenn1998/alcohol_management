import 'package:flutter/material.dart';
import 'TripDetails-style-n-function.dart';
import '../styles/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_database/firebase_database.dart';

class WorkingTripDetail extends StatefulWidget{
  final tID;
  const WorkingTripDetail({Key key, @required this.tID}) : super(key: key);
  State<WorkingTripDetail> createState() => WorkingTripDetailState(tID);

}

class WorkingTripDetailState extends State<WorkingTripDetail> with SingleTickerProviderStateMixin{
  final tID;
  var _trip;
  var _dID;
  var mapCreated = 0;
  WorkingTripDetailState(this.tID);

  //PermissionStatus _status;
  AnimationController _animationController;
  int _selectedIndex = 0;

  static double JourneyInfoHeight = 190.0;
  // Can tim cach tinh chieu cao cua JourneyInfo() widget =.="
  //////////GET USER LOCATION
  Map<String, double> curLocation;
  var location = new Location();

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController; //= Completer();
  Set<Marker>  allMarkers= {};
  Set<Polyline>_allPolylines={};



  Widget buildMap(){

    if (mapCreated == 1 && curLocation['latitude'] != null)
      mapController.moveCamera(
          CameraUpdate.newLatLng(LatLng(curLocation['latitude'], curLocation['longitude']))
      );

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
      CameraPosition(
        target:
        curLocation == null ?
        LatLng(10.03711, 105.78825): //Can Tho City
        LatLng(curLocation['latitude'], curLocation['longitude']), //user location
      //  LatLng(10.03711, 105.78825),
        zoom: 15,
      ),
      markers: allMarkers,
      onMapCreated: (GoogleMapController controller) async {
        allMarkers.clear();
        await addToList(_trip);
        mapController = controller;
       // _controller.complete(controller);
        mapCreated = 1;
      },
      myLocationEnabled : true,

    );
  }




//////////------------------------------------------------------

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('trips')
          .child(tID).onValue, //Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        _trip = snapshot.data.snapshot.value;
        _dID = _trip['dID'];
        return buildWorkingTripScreen();
      },
    );
  }

  Widget buildWorkingTripScreen(){
    //_askPermission();
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
        StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child('driver')
              .child(_trip['dID']).onValue,
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
            var _driver = snapshot.data.snapshot.value;
            return DriverInfo(_driver);
          },
        ),
//        DriverInfo(_trip),
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
                    buildMap(),
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

    location.onLocationChanged().listen((value) {
      setState(() {
        curLocation = value;

        var locationReference = FirebaseDatabase.instance.reference()
            .child('trips').child(tID).child('location');
        locationReference.update({
          'lat': curLocation["latitude"],
          'lng': curLocation["longitude"],
          //'time': DateTime.now()
        }).then((_) {
         // print("location updated DRIVER - ${_trip['dID']}");
        });

      });
    });

    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);

    //PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse)
       // .then(_updateStatus);

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
   // print(height);
   // print(JourneyInfoHeight);
    final double top = height - JourneyInfoHeight;//_PANEL_HEADER_HEIGHT ;
    final double bottom =  -JourneyInfoHeight;//_PANEL_HEADER_HEIGHT ;
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  //LOCATION ACCESS PERMISSIONNNNNNNNNN
 /* void _updateStatus(PermissionStatus status){
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
  }*/

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


      //   print("Add r2 -------------------------------------------------------------------");

    });
  }



  Widget DriverInfo(driver){
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
                      child: Text(driver['basicInfo']['name'],
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
                          Text("100", //need dynamic data
                              style: driverStatusDataStyle(0)),
                        ],
                      ),
                    ),

                    Row(
                      children: <Widget>[
                        Text("Hiện tại: ",
                            style: driverStatusTitleStyle(0)),
                        Text(driver['alcoholVal'].toString(), style:driver['alcoholVal']>=350? driverStatusDataStyle(1) : driverStatusDataStyle(0)),
                      ],
                    )


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

  Widget JourneyInfo(_trip){
    return Container(
      color: Colors.white,
      child: Column(
        //key: _keyRed,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 5.0),
                  child: Text( _trip['tID'],
                    //document[index].documentID,
                    style: const TextStyle(
                        color: const Color(0xff000000),
                        fontWeight: FontWeight.w900,
                        fontFamily: "Roboto",
                        fontStyle: FontStyle.normal,
                        fontSize: 28.0
                    ),
                  ),
                ),
              ),
            ],
          ),
          //1

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 5.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.event,
                        color: Color(0xff8391b3),
                        size: 23.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text( //"20",
                            formatDateTime(DateTime.fromMillisecondsSinceEpoch(_trip['schStart'])), //document[index].data['schStart']
                            style: timeStyleinJD()
//                              TextStyle(
//                                  color: Color(0xff0a2463),
//                                  fontWeight: FontWeight.w400,
//                                  fontFamily: "Roboto",
//                                  fontStyle: FontStyle.normal,
//                                  fontSize: 15.0)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ), //2

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.only(left: 15.0, top: 10.0),
                    child: Text(
                        "Từ:",
                        style: const TextStyle(
                            color:  const Color(0xff8391b3),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        )
                    )
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.only(left: 15.0, top: 10.0),
                    child: Text(
                        "Đến:",
                        style: const TextStyle(
                            color:  const Color(0xff8391b3),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        )
                    )
                ),
              ),
            ],
          ), //3

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 1.0),
                  child:
                  Text(
                    _trip['from'],
                    // document[index].data['from'],
                    style: TextStyle(
                        color:  Color(0xff000000),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Roboto",
                        fontStyle:  FontStyle.normal,
                        fontSize: 14.0
                    ),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, right: 15.0, top: 1.0),
                  child:
                  Text(
                    _trip['to'],

                    style: TextStyle(
                        color:  Color(0xff000000),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Roboto",
                        fontStyle:  FontStyle.normal,
                        fontSize: 14.0
                    ),
                  ),
                ),
              )
            ],
          ), //4

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.only(left: 15.0, top: 10.0),
                    child: Text(
                        "Bắt đầu lúc:",
                        style: const TextStyle(
                            color:  const Color(0xff8391b3),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        )
                    )
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.only(left: 15.0, top: 10.0),
                    child: Text(
                        "Đã chạy được:",
                        style: const TextStyle(
                            color:  const Color(0xff8391b3),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        )
                    )
                ),
              ),
            ],
          ), //5

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 1.0),
                  child:
                  Text(
                      formatDateTime(DateTime.fromMillisecondsSinceEpoch(_trip['start'])),
                      style: timeStyleinJD()
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, right: 15.0, top: 1.0),
                  child:
                  Text(
                      fromStartTime(DateTime.fromMillisecondsSinceEpoch(_trip['start'])),
                      style: timeStyleinJD()
                  ),
                ),
              )
            ],
          ), //6

        ],
      ),
    );
  }

}