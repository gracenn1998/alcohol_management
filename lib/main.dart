//import 'package:flutter/material.dart';
//import 'package:alcohol_management/menu/menu.dart';
//import 'package:alcohol_management/menu/menu_driver.dart';
//import 'package:alcohol_management/menu/menu_manager.dart';
//import './login_screen/loginScreen.dart';
//import 'login_screen/auth.dart';
//import 'root_page.dart';
//import 'login_screen/auth_provider.dart';
//import 'test/showDriverInfoScreenwChart.dart';
//import 'test/example.dart';
//
//void main() => runApp(MyApp());

//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {    return
//      AuthProvider(
//        auth: Auth(),
//        child: MaterialApp(
//            debugShowCheckedModeBanner: false,
//            title: 'Welcome to Flutter',
////            home: MyBottomMenu(),
////            home: ShowDriverInfo(dID: 'TX0003',),
//            home: SelectionCallbackExample.withSampleData(),
////            home: RootPage(),
//            theme: ThemeData(
//              primaryColor: Color(0xff0a2463),
//              backgroundColor: Colors.white,
//              scaffoldBackgroundColor: Colors.white,
//              fontFamily: 'Roboto',
//            )
//        ),
//      );
//  }
//}


import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Oscilloscope Display Example",
      home: Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  @override
  _ShellState createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<AlcoholLog> alcoholLogData = [];
  var streamSub;
  double chartWidth = 350;
  int itemCnt = 0;
  @override
  initState() {
    super.initState();

    streamSub = FirebaseDatabase.instance.reference()
        .child('trips')
        .child('HT0004')
        .child('alcoholLog')
        .onChildAdded.listen((alcoholLogSnap){

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
        itemCnt=alcoholLogData.length;
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

  DateTime _time;
  Map<String, num> _measures;


  @override
  Widget build(BuildContext context) {
    if(itemCnt > 50) {
      chartWidth = 25 + (325/50 * itemCnt);
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

    const TextStyle tempStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    // Generate the Scaffold



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
      new Center(
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
                    tickProviderSpec:new charts.BasicNumericTickProviderSpec(zeroBound: false)),
              )),
        ),
      ),
    ];

    // If there is a selection, then include the details.
    if (_time != null) {
      children.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          child: new Text(_time.toString())));
    }
    _measures?.forEach((String series, num value) {
      children.add(new Text('${series}: ${value}'));
    });

//    return new Column(children: children);

    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: Column(children: children),
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}

class AlcoholLog {
  final DateTime yyyymmddhhmm;
  final int value;

  AlcoholLog(this.yyyymmddhhmm, this.value);
}