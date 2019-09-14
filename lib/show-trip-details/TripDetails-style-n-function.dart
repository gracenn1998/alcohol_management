import 'package:flutter/material.dart';
import 'package:alcohol_management/styles/styles.dart';
import 'package:intl/intl.dart';


TextStyle TripID(){
  return TextStyle(
    fontSize: 28.0,
    fontFamily: "Rotobo",
    color: const Color(0xff000000),
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.normal,
  );
}

TextStyle timeStyleinJD(){
  return TextStyle(
      fontSize: 15,
      color: Color(0xff0a2463),
      fontFamily: "Roboto",
      fontStyle: FontStyle.normal
  );
}

TextStyle driverNameStyleinJD() {
  return TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}

String toStatusInVN(String x) {
  switch (x){
    case 'done':
      return "Đã hoàn thành";
    case 'notStarted':
      return "Chưa bắt đầu";
    case 'working':
      return "Đang đi???";
  }
  return null;
}

String formatDateTime(time) => DateFormat("dd/MM/yyyy").add_jm().format(time);

String fromStartTime(DateTime start){
  final Diff = DateTime.now().difference(start).inMinutes;
  int m = Diff % 60;
  int h = Diff ~/ 60;
  int d = h ~/24;
  h = h - 24*d;

  String tg ="";
  if (d > 0)
    tg = "$d ngày ";
  if (h > 0)
    tg = tg + "$h giờ ";
  if (m > 0)
    tg = tg + "$m phút ";

  //print("$Diff $h $m");
  return tg;
}

TextStyle tripDetailsStyle(status){
  switch (status){
    case 'normal':
      return driverInfoStyle();
    case 'done': //dahoanthanh
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xff00bc94),
      );
    case 'notStarted': //chuabatdau
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xffef3964),
      );
    case 'working': //chuabatdau
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xfff9aa33),
      ) ;
  }
}

//BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG: Do hasData work 1 cach ky cuc :)
// nen phai implement kieu ngu si nhu nayyyy tam.
/*
Widget getDriverNameByID(dID) {
  if (dID == null)
    return showDetailItem("Tài xế", "Chưa phân công", 0, 'notStarted');

  return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('drivers').where('dID', isGreaterThanOrEqualTo: dID).snapshots(),
       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
         if(snapshot.hasError){
           print('Lỗi cmnr');
         }
         else {
           if (snapshot.hasData)
             {
               print(snapshot.data.toString());
               var t = snapshot.data.documents[0];
               if (t['dID'] == dID)
                return showDetailItem("Tài xế", t['name'], 0, 'normal');
               else return showDetailItem("Tài xế", "Không tìm thấy tài xế", 0, 'notStarted');
             }
           return showDetailItem("Tài xế", "Chưa phân công", 0, 'notStarted');
         }
  }
  );
}

/*

Widget showTripID(jID){
  return
    Container(
      padding: EdgeInsets.all(10.0),
      child: Text(
        jID,
        style: TripID(),
      ),
      color: Colors.white,
    );
}
*/


Widget showDetails(trip, Tstatus) {
    String id = trip['jID'];
   // String driver = trip['dID'] == null? "Chưa phân công": trip['dID'];
    final schStart = formatDateTime(trip['schStart']);
    final start = trip['start'] == null? "Hành trình chưa bắt đầu": formatDateTime(trip['start']);
    final finish = trip['finish']== null? "Hành trình chưa bắt đầu": formatDateTime(trip['finish']);
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
*/


/*

Widget assignBtn(){
  return
  IconButton(
    icon: Icon(Icons.assignment_ind,),
    color: Color(0xffef3964),
    onPressed: () {
      //assignDialog();
    },
  );
}
*/


/*

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
          child: (title == "Tài xế" && status == "notStarted")?
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
              assignBtn()
            ],
          ): Container(
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

*/


  //----------------------------------

/*
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
                child: Text( _trip['jID'],
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
*/

/*

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
*/

/*void heightOfJourneyInfo(){
    final RenderBox renderBoxRed = _keyRed.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    print("SIZE of Red: ${sizeRed.height} ");
    JourneyInfoHeight = sizeRed.height;
  }*/

