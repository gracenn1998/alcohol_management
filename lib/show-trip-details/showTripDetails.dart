import 'package:flutter/material.dart';
import 'WorkingTripDetail_NV.dart';
import '../styles/styles.dart';
import 'TripDetails-style-n-function.dart';
import 'package:firebase_database/firebase_database.dart';
import '../edit_screens/editTripScreen.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class ShowTripDetails extends StatefulWidget{
  final String tID;
  const ShowTripDetails({Key key, @required this.tID}) : super(key: key);
  State<ShowTripDetails> createState() => ShowTripDetailsState(tID);
}

class ShowTripDetailsState extends State<ShowTripDetails> {
  final String tID;
  String _dID, _vID;


  ShowTripDetailsState(this.tID);

  List<AlcoholLog> alcoholLogData = [];
  var streamSub;
  double chartWidth = 350;
  int itemCnt = 0;
  DateTime _time;
  Map<String, num> _measures;

  @override
  initState() {
    super.initState();

    streamSub = FirebaseDatabase.instance
        .reference()
        .child('trips')
        .child(tID)
        .child('alcoholLog')
        .onChildAdded
        .listen((alcoholLogSnap) {
      var alcoVal = alcoholLogSnap.snapshot.value;
      var alcoTime = alcoholLogSnap.snapshot.key.toString();
      var yyyy, MM, dd, hh, mm;
      yyyy = int.parse(alcoTime.substring(0, 4));
      MM = int.parse(alcoTime.substring(4, 6));
      dd = int.parse(alcoTime.substring(6, 8));
      hh = int.parse(alcoTime.substring(8, 10));
      mm = int.parse(alcoTime.substring(10, 12));
      setState(() {
        alcoholLogData.add(AlcoholLog(DateTime(yyyy, MM, dd, hh, mm), alcoVal));
        itemCnt = alcoholLogData.length;
//        print(traceAlcoVal);
      });
    });
  }

  @override
  void dispose() {
//    _timer.cancel();
    streamSub.cancel();
    super.dispose();
  }



  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('trips')
          .child(tID)
          .onValue,
      //Firestore.instance.collection('journeys').where('jID', isEqualTo: jID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        var tripSnap = snapshot.data.snapshot;
        _dID = tripSnap.value['dID'];
        _vID = tripSnap.value['vID'];
        return directTripDetailScreen(tripSnap.value);
      },
    );
  }


  Widget directTripDetailScreen(trip) {
    switch (trip['status']) {
      case 'done':
        return DoneTripDetail(trip);
      case 'notStarted':
        return NotStartedTripDetail(trip);
      case 'working':
        return WorkingTripDetail_NV(tID: tID);
    }
  }

//------------------------------------------------------
  Widget DoneTripDetail(trip) {
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
        title: Center(child: Text("Thông tin hành trình", style: appBarTxTStyle,
          textAlign: TextAlign.center,)),
      ),

      body: Container(
          child: Column(
            children: <Widget>[

              buildDoneTripDetail(trip),

            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget buildDoneTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['tID']),
        showDetails(trip, 'done'),
//        alcoholLogChart(),
      ],
    );
  }


  Widget showTripID(tID) {
    return
      Container(
        height: 50.0,
        padding: EdgeInsets.all(10.0),
        child: Text(
          tID,
          style: TripID(),
        ),
        color: Colors.white,
      );
  }

  Widget getDriverNameByID(dID, Tstatus) {
    if (dID == null)
      return showDetailItem("Tài xế", "Chưa chỉ định", 0, 'notStarted');

    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('driver')
            .child(dID)
            .onValue,
        //Firestore.instance.collection('drivers').where('dID', isGreaterThanOrEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Lỗi cmnr');
          }
          else {
            if (snapshot.hasData) {
//              print(snapshot.data.toString());
              var t = snapshot.data.snapshot.value;
              if(Tstatus == 'done') {
                return showDetailItem(
                    "Tài xế", t['basicInfo']['name'], 0, 'done');
              }
              else if (t['dID'] == dID)
                return showDetailItem(
                    "Tài xế", t['basicInfo']['name'], 0, 'normal');
              else
                return showDetailItem(
                    "Tài xế", "Không tìm thấy tài xế", 0, 'notStarted');
            }
            return showDetailItem("Tài xế", "Chưa chỉ định", 0, 'notStarted');
          }
        }
    );
  }

  Widget showDetails(trip, Tstatus) {
    String id = trip['tID'];
    String vID = trip['vID'];
    DateTime formattedDate = DateTime.fromMillisecondsSinceEpoch(
        trip['schStart']);
    // String driver = trip['dID'] == null? "Chưa phân công": trip['dID'];
    final schStart = formatDateTime(formattedDate);
    final start = trip['start'] == null
        ? "Hành trình chưa bắt đầu"
        : formatDateTime(DateTime.fromMillisecondsSinceEpoch(trip['start']));
    final finish = trip['finish'] == null
        ? "Hành trình chưa bắt đầu"
        : formatDateTime(DateTime.fromMillisecondsSinceEpoch(trip['finish']));
    String from = trip['from'];
    String to = trip['to'];
    String status = toStatusInVN(trip['status']);

    return Container(
//        height: 500,
//        margin: EdgeInsets.only( bottom: 15.0),
        child: Column(
          children: <Widget>[
            showDetailItem('ID', id, 1, 'normal'),
            //           showDetailItem('Tài xế', driver, 0, (Tstatus == 'notStarted' && driver == null)?'notStarted':'normal'),
            getDriverNameByID(trip['dID'], Tstatus),
            vID == null
                ? showDetailItem(
            'Phương tiện', 'Chưa chỉ định', 1, Tstatus)
                : showDetailItem('Phương tiện', vID, 1, 'normal'),
            showDetailItem('TG dự kiến', schStart, 0, 'normal'),
            showDetailItem('TG bắt đầu', start, 1,
                (Tstatus == 'notStarted') ? 'notStarted' : 'normal'),
            showDetailItem('TG kết thúc', finish, 0,
                (Tstatus == 'notStarted') ? 'notStarted' : 'normal'),
            showDetailItem('Từ', from, 1, 'normal'),
            showDetailItem('Đến', to, 0, 'normal'),
            showDetailItem('Trạng Thái', status, 1, Tstatus),
          ],
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
              decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
              //             <--- BoxDecoration here
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
            child: (title == "Tài xế") ?
            Container(
              height: 55.0,
//          margin: const EdgeInsets.all(5.0),
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
              child: Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$data",
                      style: tripDetailsStyle(status),
                    ),
                  ),
                  status != 'done'? assignDriverBtn(): Container(),
                ],
              ),
            ) :
            (title == "Phương tiện") ?

            Container(
              height: 55.0,
//          margin: const EdgeInsets.all(5.0),
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
              child: Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$data",
                      style: tripDetailsStyle(status),
                    ),
                  ),
                  status != 'done'? assignVehicleBtn(): Container()
                ],
              ),
            ) :
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
  Widget assignDriverBtn(){
    return
      IconButton(
        icon: Icon(Icons.assignment_ind,),
        color: Color(0xffef3964),
        onPressed: () {
          assignDriverDialog();
        },
      );
  }

  Widget assignVehicleBtn() {
    return
      IconButton(
        icon: Icon(Icons.directions_car,),
        color: Color(0xffef3964),
        onPressed: () {
          assignVehicleDialog();
        },
      );
  }
  String selectedDID = null;
  String selectedVID = null;




  void assignDriverDialog() {
    selectedDID = null;
    final _dIDControler = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Chỉ định"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {

              _dIDControler.addListener(() {
                setState(() {});
              });

              Widget getListSearchView(documents) {
                if(documents == null || documents.length == 0)
                  return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {},
                      separatorBuilder: (context, index) {},
                      itemCount: 0
                  );

                return ListView.separated(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    String name = documents[index]['basicInfo']['name'].toString();
                    String dID = documents[index]['dID'].toString();
                    return InkWell(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
//                padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
                            color: selectedDID==dID? Colors.blueAccent : Colors.white,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  name,
                                  style: driverInfoStyle(),
                                ),
                                Text(
                                  " {$dID}",
                                  style: driverInfoStyle(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState((){
                          selectedDID = dID;
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                );
              }
              return Container(
                height: 300,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _dIDControler,
                      decoration: InputDecoration(
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff00BC94))
                        ),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff00BC94))
                        ),
                        hintText: "tên tài xế",
                        labelText: "Nhập tên tài xế để tìm kiếm",
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 500,
                        height: 500,
                        child: StreamBuilder(
                          stream: FirebaseDatabase.instance.reference().child('driver')
                              .orderByChild('basicInfo/name')
                              .startAt(_dIDControler.text.toUpperCase()).endAt(_dIDControler.text.toLowerCase() + '\uf8ff')
                              .onValue,
                          builder: (BuildContext context, AsyncSnapshot snapshots) {
                            if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
                            else {
                              List<dynamic> driverList;
                              DataSnapshot driverSnaps = snapshots.data.snapshot;
                              Map<dynamic, dynamic> map = driverSnaps.value;
                              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
                              if (map != null) { /*To not show the deleted drivers*/
                                driverList = map.values.toList();
                                for (int i = 0; i<driverList.length; ++i) {
//                              debugPrint(driverList[i]['isDeleted'].toString());
                                  if (driverList[i]['isDeleted']) driverList.removeAt(i);
                                }
                              }
                              //..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));
                              return getListSearchView(driverList);
                            }
                          },
                        ),
                      ),
                    )

                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Xác nhận"),
              onPressed: () {
                updateDriver();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void assignVehicleDialog() {
    selectedVID = null; //sau chuyen thanh bien so xe???
    final _vIDControler = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Chỉ định"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {

              _vIDControler.addListener(() {
                setState(() {});
              });

              Widget getListSearchView(documents) {
                if(documents == null || documents.length == 0)
                  return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {},
                      separatorBuilder: (context, index) {},
                      itemCount: 0
                  );

                return ListView.separated(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
//                    String name = documents[index]['basicInfo']['name'].toString();
                    String vID = documents[index]['vID'].toString();
                    return InkWell(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
//                padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 10.0),
                            color: selectedVID==vID? Colors.blueAccent : Colors.white,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "<Biển số xe>",
                                  style: driverInfoStyle(),
                                ),
                                Text(
                                  " {$vID}",
                                  style: driverInfoStyle(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState((){
                          selectedVID = vID;
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                );
              }
              return Container(
                height: 300,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _vIDControler,
                      decoration: InputDecoration(
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff00BC94))
                        ),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff00BC94))
                        ),
                        hintText: "mã phương tiện",
                        labelText: "Nhập mã phương tiện để tìm kiếm",
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 500,
                        height: 500,
                        child: StreamBuilder(
                          stream: FirebaseDatabase.instance.reference().child('vehicles')
                              .orderByChild('vID')
                              .startAt(_vIDControler.text.toUpperCase()).endAt(_vIDControler.text.toLowerCase() + '\uf8ff')
                              .onValue,
                          builder: (BuildContext context, AsyncSnapshot snapshots) {
                            if (snapshots.connectionState == ConnectionState.waiting) return LoadingState;
                            else {
                              List<dynamic> vehicleList;
                              DataSnapshot vehicleSnaps = snapshots.data.snapshot;
                              Map<dynamic, dynamic> map = vehicleSnaps.value;
                              //add  the snaps value for index usage -- snaps[index] instead of snaps['TX0003'] for ex.
                              if (map != null) { /*To not show the deleted drivers*/
                                vehicleList = map.values.toList();
                                for (int i = 0; i<vehicleList.length; ++i) {
//                              debugPrint(driverList[i]['isDeleted'].toString());
                                  if (vehicleList[i]['isDeleted']) vehicleList.removeAt(i);
                                }
                              }
                              //..sort((a, b) => b['alcoholVal'].compareTo(a['alcoholVal']));
                              return getListSearchView(vehicleList);
                            }
                          },
                        ),
                      ),
                    )

                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Xác nhận"),
              onPressed: () {
                updateVehicle();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateVehicle() {
    FirebaseDatabase.instance.reference().child('trips').child(tID).update(
        {
          'vID':selectedVID,
        }
    );

    FirebaseDatabase.instance.reference().child('vehicles').child(
        selectedVID).update(
        {
          'tID': tID,
          'dID' : _dID,
        }
    );
  }

  void updateDriver() {
    FirebaseDatabase.instance.reference().child('trips').child(tID).update(
        {
          'dID': selectedDID,
        }
    );

    FirebaseDatabase.instance.reference().child('vehicles').child(
        _vID).update(
        {
          'dID': selectedDID,
          'tID': tID
        }
    );
  }

  Widget alcoholLogChart() {
    if (itemCnt > 50) {
      chartWidth = 25 + (325 / 50 * itemCnt);
    }
    List<charts.Series<AlcoholLog, DateTime>> _createSampleData() {
      return [
        new charts.Series<AlcoholLog, DateTime>(
          id: 'Nồng độ cồn',
          domainFn: (AlcoholLog log, _) => log.yyyymmddhhmm,
          measureFn: (AlcoholLog log, _) => log.value,
          data: alcoholLogData,
        )
      ];
    }

    // Listens to the underlying selection changes, and updates the information
    // relevant to building the primitive legend like information under the
    // chart.
    _onSelectionChanged(charts.SelectionModel model) {
      final selectedDatum = model.selectedDatum;

      DateTime time;
      final measures = <String, num>{};

      // We get the model that updated with a list of [SeriesDatum] which is
      // simply a pair of series & datum.
      //
      // Walk the selection updating the measures map, storing off the sales and
      // series name for each selection point.
      if (selectedDatum.isNotEmpty) {
        time = selectedDatum.first.datum.yyyymmddhhmm;
        selectedDatum.forEach((charts.SeriesDatum datumPair) {
          measures[datumPair.series.displayName] = datumPair.datum.value;
        });
      }

      // Request a build.
      setState(() {
        _time = time;
        _measures = measures;
      });
    }

    final children = <Widget>[
    ];

    // If there is a selection, then include the details.
    if (_time != null) {
      children.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          child: new Text(formatDateTime(_time))));
    }
    _measures?.forEach((String series, num value) {
      children.add(new Text('${series}: ${value}'));
    });

    children.add(Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
            height: 300.0,
            width: chartWidth,
            child: new charts.TimeSeriesChart(
              _createSampleData(),
              animate: false,
              selectionModels: [
                new charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info,

                  changedListener: _onSelectionChanged,
                )
              ],
              primaryMeasureAxis: new charts.NumericAxisSpec(
                  tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                      zeroBound: false)),
            )),
      ),
    ));

//    return new Column(children: children);

    return Column(children: children);
  }

  //--------------------------------------------------------

  Widget NotStartedTripDetail(trip){
//>>>>>>> smartConfig
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
        title: Center(child: Text("Thông tin hành trình", style: appBarTxTStyle,
          textAlign: TextAlign.center,)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.edit),
              color: Color(0xff06E2B3),
              onPressed: () {
                final page =  EditTrip(
                    key: PageStorageKey('editTrip'),
                    tID: tID
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page)
                );
              }, // EDITTTTTTTT
            ),
          ),
        ],
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              showTripID(trip['tID']),
              Expanded(
                child: SingleChildScrollView(
                  child: showDetails(trip, 'notStarted'),
                ),
              ),
            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget buildNotStartedTripDetail(trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['tID']),
        showDetails(trip, 'notStarted')
      ],
    );
  }
}
class AlcoholLog {
  final DateTime yyyymmddhhmm;
  final int value;

  AlcoholLog(this.yyyymmddhhmm, this.value);
}

