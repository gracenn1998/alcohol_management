import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../edit_screens/editDriverScreen.dart';
//import './showAllDrivers.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class ShowDriverInfo extends StatefulWidget {
  final String dID;
  const ShowDriverInfo({Key key, @required this.dID}) : super(key: key);
  @override
  _ShowDriverInfoState createState() => _ShowDriverInfoState(dID);
}


class _ShowDriverInfoState extends State<ShowDriverInfo> {
  String dID;
  _ShowDriverInfoState(this.dID);

  static const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);



  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
//    if(_selectedIndex == -1) {
//      return ShowAllDrivers(
//        key: PageStorageKey("showAll"),
//      );
//    }
    if(_selectedIndex == 1) {
      return EditDriverInfo(
        key: PageStorageKey("editInfo"),
        dID: dID,
      );
    }

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xff06E2B3),
            onPressed: () {
              //backkkk
              setState(() {
                _selectedIndex--;
              });
            },
          ),
          title:  Center(child: Text('Thông tin tài xế', style: appBarTxTStyle, textAlign: TextAlign.center,)),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: Icon(Icons.edit),
                color: Color(0xff06E2B3),
                onPressed: () {
                  //editttt
                setState(() {
                  _selectedIndex = 1;
                });
//                  Navigator.push(context, MaterialPageRoute(builder: (context) {
//                    return EditDriverInfo(
//                      dID: dID,
//                    );
//                  }));
                },
              ),
            ),
          ],
        ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('drivers').where('dID', isEqualTo: dID).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: Text('Loading...', style: tempStyle,),);
          return showAllInfo(snapshot.data.documents[0]);
        },
      ),
      resizeToAvoidBottomPadding: false,
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//
//        },
//        child: Icon(Icons.gps_fixed),
//        tooltip: 'Xác định vị trí xe đang ở',
//      ),

    );
  }

  Widget showAllInfo(driver) {
    return Column(
      children: <Widget>[
        showBasicInfo(driver['name']),
        Expanded(
            child: showDetails( driver['dID'], driver['idCard'],
                driver['address'], driver['email'],
                driver['gender'], driver['dob'])
        ),
        generatePasswordButton(),
//        sample2(context),
      ],
    );
  }

  Widget showBasicInfo(name) {
    String onWorking, alcoholTrack, tripCode;
    int status = -1;

    return Container(
        height: 120.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 15.0),
                child: CircleAvatar(
                  radius: 45.0,
                  backgroundImage: AssetImage('images/avatar.png'),
                )
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text("$name", style: driverNameStyle()),
                    ),
                    StreamBuilder(
                      stream: FirebaseDatabase.instance.reference().child('driver')
                          .child('$dID').onValue,
                      builder: (BuildContext context, snapshot) {
                        if(!snapshot.hasData) {

                          return Center(child: CircularProgressIndicator());
                        }
                        else if(snapshot.hasData) {
                          if(snapshot.data.snapshot.value == null) {
                            onWorking = 'Đang nghỉ';
                            alcoholTrack = 'Không hoạt động';
                            status = -1;
                          }
                          else {
                            tripCode = snapshot.data.snapshot.value['tripCode'];
                            var alcoholVal = snapshot.data.snapshot.value['alcoholVal'];
                            if(alcoholVal <= 350) {
                              onWorking = 'Đang làm việc';
                              alcoholTrack = alcoholVal.toString();
                              status = 0;
                            }
                            else {
                              onWorking = 'Say xỉn';
                              alcoholTrack = alcoholVal.toString();
                              status = 1;
                            }
                          }

                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Trạng thái: ", style: driverStatusTitleStyle(status)),
                                          Text("$onWorking", style: driverStatusDataStyle(status)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text("Chỉ số cồn: ", style: driverStatusTitleStyle(status)),
                                        Text("$alcoholTrack", style: driverStatusDataStyle(status)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              status >= 0 ?
                              Container(
                                margin: EdgeInsets.only(right: 10.0),
                                child: IconButton(
                                  padding: EdgeInsets.only(right: 1.0, bottom: 1.0),
                                  icon: Icon(
                                    Icons.local_library,
                                    color: Color(0xff06E2B3),
                                    size: 25.0,
                                  ),
                                  tooltip: 'Xem hành trình tài xế đang làm việc',
                                  onPressed: () {

                                    //return journey detail
                                    print(tripCode);
                                  },
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xff0a2463),
                                  borderRadius: new BorderRadius.all(const  Radius.circular(25.0)),
                                ),
                              ):Container(),
                            ],
                          );
                        }
//                          else if(snapshot.hasError) => return "Error";
                      },
                    ),
                  ],
                )
              ),
            ),



          ],
        )

    );

  }

  Widget generatePasswordButton() {
    return Container(
      height: 45.0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 15.0),
//    padding: const EdgeInsets.all(5.0),
      child: RaisedButton(
        child: Text(
            "Tạo mật khẩu mới",
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
            )
        ),
        elevation: 6.0,
        onPressed: () {
          //action
          debugPrint("New pw generated");
        },
      ),
    );
  }

}

Widget showDetails(id, idCard, address, email, gender, dob) {
  final df = new DateFormat('dd/MM/yyyy');
  var formattedDOB = df.format(dob);
  return Container (
      margin: EdgeInsets.only( bottom: 15.0),
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showDetailItem('ID', id, 1),
//            showDetailInfo('Tuổi', '40', 0 ),
              showDetailItem('CMND', idCard, 0),
              showDetailItem('Địa chỉ', address, 1),
              showDetailItem('Email', email, 0),
              showDetailItem('Giới tính', gender=='M'?'Nam':'Nữ', 1 ),
              showDetailItem('Ngày sinh', formattedDOB, 0),
              sample1(),
//              sample(),
            ],
          )
      )
  );

}

Widget showDetailItem(title, data, line) {
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
        child: Container(
          height: 55.0,
//          margin: const EdgeInsets.all(5.0),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          decoration: line == 1 ? oddLineDetails() : evenLineDetails(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$data",
              style: driverInfoStyle(),
            ),

          ),
        ),
      ),
    ],

  );
}

Widget sample1() {
  return StreamBuilder(
    stream: FirebaseDatabase.instance.reference().child('trips')
      .child('HT0002').onValue,
    builder: (BuildContext context, snapshot) {
      if (!snapshot.hasData) {

      }
      else {
        DataSnapshot tripSnaps = snapshot.data.snapshot;
        List<DataPoint<double>> dataList = [];
        tripSnaps.value['alcoholLog'].forEach((key, val){
//          print(key);
//          print(values); // omitting "[keys]" from the OPs approach
          dataList.add(
            DataPoint(value: val.toDouble(), xAxis: int.parse(key).toDouble())
          );
        });
        dataList..sort((a, b) => a.xAxis.compareTo(b.xAxis));
//        const constList = dataList.;

        return Center(
          child: Container(
            color: Colors.red,
            height: 200.0,//MediaQuery.of(context).size.height / 2,
            width: 500.0,//MediaQuery.of(context).size.width * 0.9,
            child: BezierChart(
              bezierChartScale: BezierChartScale.CUSTOM,
              xAxisCustomValues: const [0, 5, 10, 15, 20, 25, 30, 31, 42, 53, 64],
              series: const [
                BezierLine(
                  data:
                  const [
                    DataPoint<double>(value: 10, xAxis: 0),
                    DataPoint<double>(value: 130, xAxis: 5),
                    DataPoint<double>(value: 50, xAxis: 10),
                    DataPoint<double>(value: 150, xAxis: 15),
                    DataPoint<double>(value: 75, xAxis: 20),
                    DataPoint<double>(value: 0, xAxis: 25),
                    DataPoint<double>(value: 5, xAxis: 30),
                    DataPoint<double>(value: 45, xAxis: 31),
                    DataPoint<double>(value: 45, xAxis: 42),
                    DataPoint<double>(value: 45, xAxis: 53),
                    DataPoint<double>(value: 45, xAxis: 64),
                  ],
                ),
              ],
              config: BezierChartConfig(
                verticalIndicatorStrokeWidth: 3.0,
                verticalIndicatorColor: Colors.black26,
                showVerticalIndicator: true,
                contentWidth: 1000,
                backgroundColor: Color(0xff0a2463),
                snap: false,
              ),
            ),
          ),
        );
      }
    });
}
