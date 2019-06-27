/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import 'package:backdrop/backdrop.dart';
import 'editJourney.dart';
import '../styles/journeyDetailStyle.dart';


class WorkingJourneyDetail extends StatefulWidget
{
  WorkingJourneyDetailState createState() => WorkingJourneyDetailState();
}

class WorkingJourneyDetailState extends State<WorkingJourneyDetail> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  static const _PANEL_HEADER_HEIGHT = 32.0;

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DriverInfo(),
        BackDropContainer(),
        //JourneyInfo()
      ],
    );
  }

  Widget DriverInfo(){
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
                      child: Text("Trần văn A",
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
                    Row(
                      children: <Widget>[
                        Text("Hiện tại: ",
                            style: driverStatusTitleStyle(0)),
                        Text("500", style: driverStatusDataStyle(1)),
                      ],
                    ),
                  ],
                )),
            //Ten + Trang thai
            Expanded(

              // padding: EdgeInsets.only(left: 15.0, right:15.0),
              child: Container(
                child: RaisedButton(
                  child: Text("XỬ LÝ", style: TextStyle(color: Colors.white),),
                  color: Color(0xffef3964),
                  onPressed: () {
                    //Xoa driver
                    print("XULYYYYYYYYyyy");

                    print(MediaQuery.of(context).size.height );

                    print(MediaQuery.of(context).size.width );
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

  Widget JourneyInfo(){
    return Container(
      constraints:
      BoxConstraints.expand(
          height: MediaQuery.of(context).size.height - 120 -128,
          width: MediaQuery.of(context).size.width
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, top: 5.0),
                  child: Text( 'HT0004',
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
                        child: Text(
                            '12/7/2019 - 3:00pm', //document[index].data['schStart']
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
                    '154 Lý Tự Trọng, P. An Cư, Q. Ninh Kiều, TPCT',
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
                    '12A Nguyễn Văn Cừ Nối Dài, P. An Lạc, Q. Ninh Kiều, TPCT',

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
                      '24/06/2019 - 3:15pm',
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
                      '17 phút',
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

  Widget BackDropContainer(){
    return Container(
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LayoutBuilder(
              builder: _buildStack,
            ),
          ],
        )
    );
  }

  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);
  }

  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  bool get _isPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> animation = _getPanelAnimation(constraints);
    final ThemeData theme = Theme.of(context);
    return new Container(
      color: theme.primaryColor,
      child: new Stack(
        children: <Widget>[
          new Container(
            child:JourneyInfo(),

          ),
          new PositionedTransition(
            rect: animation,
            child: new Material(
              borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0)),
              elevation: 0,
              child:
              new Container(
                color: Colors.blueGrey,
                height:  30.0,
                child:
                Center(child: new Text("panel")),
              ),
            ),
          )],
      ),
    );
  }

  Animation<RelativeRect> _getPanelAnimation(BoxConstraints constraints) {
    final double height = 500;
    final double top = height - _PANEL_HEADER_HEIGHT ;
    final double bottom = -_PANEL_HEADER_HEIGHT;

    print("height $height, top $top, bot $bottom");
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _controller, curve: Curves.linear));
  }


} //end class*/


//    PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse)
//        .then(_updateStatus);


//Permission_handler (AndroidX =.=")
/*PermissionStatus _status;

  @override


  void _updateStatus(PermissionStatus status){
    print("$status");
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
//GoogleMap test
/*
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _default = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Widget buildMap(){
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962),
        zoom: 14.4746,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationEnabled : true,
    );
  }*/