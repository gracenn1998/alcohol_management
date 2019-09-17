import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'TripDetails-style-n-function.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:smartconfig/smartconfig.dart';



class ShowTripDetails extends StatefulWidget{
  final String tID;
  const ShowTripDetails({Key key, @required this.tID}) : super(key: key);
  State<ShowTripDetails> createState() => ShowTripDetailsState(tID);
}

class ShowTripDetailsState extends State<ShowTripDetails>{
  final String tID;
  ShowTripDetailsState(this.tID);

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
//
//  var wifiBSSID = await (Connectivity().getWifiBSSID());
//  var wifiIP = await (Connectivity().getWifiIP());network
//  var wifiName = await (Connectivity().getWifiName());wifi network

  @override
  initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Widget build(BuildContext context){
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('trips')
          .child(tID).onValue, //Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return directTripDetailScreen(snapshot.data.snapshot.value);
      },
    );
  }

  Widget directTripDetailScreen(trip){
    switch (trip['status']){
      case 'done':
        return DoneTripDetail(trip);
      case 'notStarted':
        return NotStartedTripDetail(trip);
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
//            setState(() {
//              _selectedIndex--;
//            });
            Navigator.pop(context);
          }, //BACKKKKK
        ),
        title:  Center(child: Text("Thông tin hành trình", style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              showTripID(trip['tID']),
              Expanded(
                child: SingleChildScrollView(
                  child: showDetails(trip, 'done'),
                ),
              ),
            ],
          )
      ),
      resizeToAvoidBottomPadding: false,
    );

  }

  Widget showTripID(tID){
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: Text(
            tID,
            style: TripID(),
          ),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget getDriverNameByID(dID) {
    if (dID == null)
      return showDetailItem("Tài xế", "Chưa phân công", 0, 'notStarted');

    return StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('driver')
            .child(dID).onValue,//Firestore.instance.collection('drivers').where('dID', isGreaterThanOrEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            print('Lỗi cmnr');
          }
          else {
            if (snapshot.hasData)
            {
//              print(snapshot.data.toString());
              var t = snapshot.data.snapshot.value;
              if (t['dID'] == dID)
                return showDetailItem("Tài xế", t['basicInfo']['name'], 0, 'normal');
              else return showDetailItem("Tài xế", "Không tìm thấy tài xế", 0, 'notStarted');
            }
            return showDetailItem("Tài xế", "Chưa phân công", 0, 'notStarted');
          }
        }
    );
  }

  Widget showDetails(trip, Tstatus) {
    String id = trip['tID'];
    String vID = trip['vID'];
    DateTime formattedDate = DateTime.fromMillisecondsSinceEpoch(trip['schStart']);
    // String driver = trip['dID'] == null? "Chưa phân công": trip['dID'];
    final schStart = formatDateTime(formattedDate);
    final start = trip['start'] == null? "Hành trình chưa bắt đầu": formatDateTime(DateTime.fromMillisecondsSinceEpoch(trip['start']));
    final finish = trip['finish']== null? "Hành trình chưa bắt đầu": formatDateTime(DateTime.fromMillisecondsSinceEpoch(trip['finish']));
    String from = trip['from'];
    String to = trip['to'];
    String status = toStatusInVN(trip['status']);

    return Container (
        margin: EdgeInsets.only( bottom: 15.0),
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showDetailItem('ID', id, 1, 'normal'),
                //           showDetailItem('Tài xế', driver, 0, (Tstatus == 'notStarted' && driver == null)?'notStarted':'normal'),
                getDriverNameByID(trip['dID']),
                vID==null
                    ?showDetailItem('Phương tiện', 'Chưa chỉ định', 0, 'notStarted')
                    :showDetailItem('Phương tiện', vID, 0, 'normal'),
                showDetailItem('TG dự kiến', schStart, 1, 'normal'),
                showDetailItem('TG bắt đầu', start, 0, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('TG kết thúc', finish, 1, (Tstatus == 'notStarted')?'notStarted':'normal'),
                showDetailItem('Từ', from, 0, 'normal'),
                showDetailItem('Đến', to, 1, 'normal'),
                showDetailItem('Trạng Thái', status, 0, Tstatus),
              ],
            )
        )
    );

  }


  Widget showDetailItem(title, data, line, status) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
              height: 55.0,
//          margin: const EdgeInsets.all(5.0),
              padding: EdgeInsets.only(left: 25.0),
              decoration: line == 1 ? oddLineDetails() : evenLineDetails(), //             <--- BoxDecoration here
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "$title",
                  style: driverInfoStyle(),
                ),
              )
          ),
        ),
        Expanded(
            flex: 5,
            child: (title == "Tài xế")?
            Row(
              children: <Widget>[
                Container(
                  height: 55.0,
//          margin: const EdgeInsets.all(5.0),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$data",
                      style: tripDetailsStyle(status),
                    ),
                  ),
                ),
              ],
            ):
            (title == "Phương tiện")?
            Row(
              children: <Widget>[
                Container(
                  height: 55.0,
//          margin: const EdgeInsets.all(5.0),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$data",
                      style: tripDetailsStyle(status),
                    ),
                  ),
                ),
              ],
            ):
            Container(
              height: 55.0,
//          margin: const EdgeInsets.all(5.0),
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "$data",
                  style: tripDetailsStyle(status),
                ),
              ),
            )

        ),
      ],

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
//            setState(() {
//              _selectedIndex--;
//            });
            Navigator.pop(context);
          }, //BACKKKKK
        ),
        title:  Center(child: Text("Thông tin hành trình", style: appBarTxTStyle, textAlign: TextAlign.center,)),
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: showTripID(trip['tID']),
                  ),
                  Expanded(
                      child: IconButton(
                        icon: Icon(Icons.wifi),
                        color: Color(0xff0a2463),
                        iconSize: 35.0,
                        tooltip: 'Thiết lập wifi',
                        onPressed: (){
                          wifiSmartConfig(context);
                        },
                      )
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: showDetails(trip, 'notStarted'),
                ),
              ),
              buildStartBtn()
            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  void wifiSmartConfig(context) {

    final TextEditingController _bssidFilter = new TextEditingController();
    final TextEditingController _ssidFilter = new TextEditingController();
    final TextEditingController _passwordFilter = new TextEditingController();

    bool _isLoading = false;

    String _ssid = "";
    String _bssid = "";
    String _password = "";
    String _msg = "";

    Connectivity().getWifiBSSID().then((result) {
//      _bssid = result;
      _bssidFilter.text = result;
    });
    Connectivity().getWifiName().then((result) {
//      _ssid = result;
      _ssidFilter.text = result;
    });



    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Thiết lập Wifi"),
          content: Container(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    'Vui lòng kết nối với đúng Wifi cần thiết lập để nhận thông tin BSSID chính xác',
                    style: TextStyle(
                      color: Color(0xffef3964),
                    )
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      focusedBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      labelText: "Tên Wifi",
                    ),
                    controller: _ssidFilter,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      focusedBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      labelText: "Mật khẩu",
                    ),
                    controller: _passwordFilter,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      focusedBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00BC94))
                      ),
                      labelText: "BSSID",
                    ),
                    controller: _bssidFilter,
                  )
                ],
              ),
            ),
          ),

          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Xác nhận"), //????????? chữ gì
              onPressed: () {
                void smartConfig() async {
                  Smartconfig.start(
                      _ssidFilter.text,
                      _bssidFilter.text,
                      _passwordFilter.text
                  ).then((onValue){
                    print("sm version $onValue");
                  });
                }
                smartConfig();
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildStartBtn(){
    return Container(
      color: Color(0xff0a2463) ,
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      margin: EdgeInsets.only(bottom: 10, top: 10),
      child: FlatButton(
        child: Text('BẮT ĐẦU HÀNH TRÌNH', style: TextStyle(color: Colors.white, fontSize: 18),),
        onPressed: (){
          print("Start button tapped");
        },
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }


}



