import 'package:flutter/material.dart';
import 'WorkingTripDetail_NV.dart';
import '../styles/styles.dart';
import 'TripDetails-style-n-function.dart';
import '../styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../edit_screens/editTripScreen.dart';


class ShowTripDetails extends StatefulWidget{
  final String tID;
  const ShowTripDetails({Key key, @required this.tID}) : super(key: key);
  State<ShowTripDetails> createState() => ShowTripDetailsState(tID);
}

class ShowTripDetailsState extends State<ShowTripDetails>{
  final String tID;
  final _dIDControler = TextEditingController();
  final _vIDControler = TextEditingController();

  ShowTripDetailsState(this.tID);
  int _selectedIndex = 0;
  /*if(_selectedIndex == -1) {
      return ShowAllJourneys();
    }
    if(_selectedIndex == 1) {
      return EditJourney(
        jID: jID,
      );
    }*/

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
      case 'working':
        return WorkingTripDetail_NV(tID: tID);

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
        showDetails(trip, 'done')
      ],
    );
  }


  Widget showTripID(tID){
    return
      Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          tID,
          style: TripID(),
        ),
        color: Colors.white,
      );
  }

  Widget getDriverNameByID(dID) {
    if (dID == null)
      return showDetailItem("Tài xế", "Chưa chỉ định", 0, 'notStarted');

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
            return showDetailItem("Tài xế", "Chưa chỉ định", 0, 'notStarted');
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
                assignDriverBtn()
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
                assignVehicleBtn()
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

  Widget assignVehicleBtn(){
    return
      IconButton(
        icon: Icon(Icons.directions_car,),
        color: Color(0xffef3964),
        onPressed: () {
          assignVehicleDialog();
        },
      );
  }

  void assignDriverDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Chỉ định"),
          content: Container(
            child: TextFormField(
              controller: _dIDControler,
              decoration: InputDecoration(
                enabledBorder: new UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00BC94))
                ),
                focusedBorder: new UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00BC94))
                ),
                hintText: "Nhập mã tài xế",
                labelText: "Mã tài xế",
              ),
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Xác nhận"), //????????? chữ gì
              onPressed: () {
                updateDriver();
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
  void assignVehicleDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Chỉ định"),
          content: Container(
            child: TextFormField(
              controller: _vIDControler,
              decoration: InputDecoration(
                enabledBorder: new UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00BC94))
                ),
                focusedBorder: new UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00BC94))
                ),
                hintText: "Nhập mã phương tiện",
                labelText: "Mã phương tiện",
              ),
            ),
          ),

          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Xác nhận"), //????????? chữ gì
              onPressed: () {
                updateVehicle();
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

  void updateVehicle(){
    FirebaseDatabase.instance.reference().child('trips').child(tID).update(
        {
          'vID': _vIDControler.text,
        }
    );

    FirebaseDatabase.instance.reference().child('vehicles').child(_vIDControler.text).update(
        {
          'tID': tID
        }
    );


  }

  void updateDriver(){
    FirebaseDatabase.instance.reference().child('trips').child(tID).update(
        {
          'dID': _dIDControler.text,
        }
    );

    FirebaseDatabase.instance.reference().child('vehicles').child(_vIDControler.text).update(
        {
          'dID': _dIDControler.text,
          'tID': tID
        }
    );


  }


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
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Icon(Icons.edit),
              color: Color(0xff06E2B3),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditTrip(
                        key: PageStorageKey('editTrip'),
                        tID: tID)
                    )
                );
              }, // EDITTTTTTTT
            ),
          ),
        ],
      ),

      body: Container(
          child: Column(
            children: <Widget>[
              buildNotStartedTripDetail(trip),
            ],
          )

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget buildNotStartedTripDetail(trip){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showTripID(trip['tID']),
        showDetails(trip, 'notStarted')
      ],
    );
  }

}



