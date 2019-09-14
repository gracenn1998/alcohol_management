import 'package:flutter/material.dart';
import 'TripDetails-style-n-function.dart';
import '../styles/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_database/firebase_database.dart';

class WorkingTripDetail_NV extends StatefulWidget{
  final tID;
  const WorkingTripDetail_NV({Key key, @required this.tID}) : super(key: key);
  State<WorkingTripDetail_NV> createState() => WorkingTripDetail_NVState(tID);

}


class WorkingTripDetail_NVState extends State<WorkingTripDetail_NV> with SingleTickerProviderStateMixin{
  final tID;
  var _trip;
  var mapCreated = 0;
  WorkingTripDetail_NVState(this.tID);

  //PermissionStatus _status;
  AnimationController _animationController;
  int _selectedIndex = 0;

  static double TripInfoHeight = 190.0;
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
          position: new LatLng(Lat, Lng),
          infoWindow: InfoWindow(title: "Driver"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
      )
    ;
    allMarkers.add(driverMarker);
    //print("MODIFYYYYYYYYYYYYYYYYY MARKER CALLLLLLLLLLLLLL");
//    print(allMarkers);
//    print("MODIFYYYYYYYYYYYYYYYYY MARKER CALLLLLLLLLLLLLL222222222222");
       return allMarkers;
  }

  Widget buildMap(driver){

    //print("buildMap: $driver");
    //print("buildMap: $allMarkers");
    if (driver['lat'] != null && mapCreated == 1)
      mapController.moveCamera(
          CameraUpdate.newLatLng(LatLng(driver['lat'], driver['lng']))
      );

    return new GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
      CameraPosition(
        target:
        driver == null ?
        LatLng(10.03711, 105.78825): //Can Tho City
        LatLng(driver['lat'], driver['lng']), //user location
        zoom: 15.0,
      ),
      markers: modifyMarker(driver['lat'], driver['lng']),
      onMapCreated: (GoogleMapController controller) async {
        allMarkers.clear();
        await addToList(_trip);
      //  print("Create mappppppppppppppppppppppp");
      //  print(allMarkers);
        mapController = controller;
        //_controller.complete(controller);
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
       // print("Build func: streambuilder on Firestore_______________________________");

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
        DriverInfo(_trip),
        new Stack(
          children: <Widget>[
            new Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(
                  height: constraints.biggest.height - 120.0
              ),
            ),
            TripInfo(_trip),
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
                          //print("_buildStack: Listen on driver location changed: $driver");

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

   /* PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);*/

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

    final double height = constraints.biggest.height - 200.0 ;
   // print(height);
   // print(JourneyInfoHeight);
    final double top = height - TripInfoHeight;//_PANEL_HEADER_HEIGHT ;
    final double bottom =  -TripInfoHeight;//_PANEL_HEADER_HEIGHT ;
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _animationController, curve: Curves.linear));
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


  Widget DriverInfo(_trip){
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
                            .child(_trip['dID']).child('alcoholVal').onValue,
                        builder: (BuildContext context, snapshot) {
                          if(!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          else if(snapshot.hasData) {
                            var alcoholVal = snapshot.data.snapshot.value;
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



  Widget TripInfo(_trip){
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
                            formatDateTime(_trip['schStart']), //document[index].data['schStart']
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
                      formatDateTime(_trip['start']),
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
                      fromStartTime(_trip['start']),
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