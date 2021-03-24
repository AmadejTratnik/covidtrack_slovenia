import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'API.dart';
import 'Podatki.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

bool _isInitialized = false;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Covid-19 sledilnik',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: PrvaStran(),
    );
  }
}

class PrvaStran extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PodatkiState();
}

class _PodatkiState extends State {
  // ignore: deprecated_member_use
  var podatki = new List<Podatek>();

  Future<void> _getStats() async {
    API.getStats().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        podatki = list.map((model) => Podatek.fromJson(model)).toList();
        if (podatki != null || podatki.length != 0) {
          podatki.removeLast();
        }
        _isInitialized = true;
      });
    });
  }

  initState() {
    super.initState();
    _getStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      int dan = podatki.last.day;
      int mesec = podatki.last.month;
      int leto = podatki.last.year;
      String datum =
          dan.toString() + '.' + mesec.toString() + '.' + leto.toString();
      return new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            'Podatki veljajo za dan: $datum',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: _listIzKartic(podatki, context),
      );
    } else {
      return new Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nalaganje podatkov...'),
                  CircularProgressIndicator()
                ]),
          ));
    }
  }
}

Widget _listIzKartic(List<Podatek> podatki, BuildContext context) =>
    ListView(children: [
      _kartica('', 'Dnevno število testiranj PCR:', getPerformedTests(podatki),
          Colors.green, context),
      _kartica('', 'Dnevno število potrjenih primerov:',
          getPositiveTests(podatki), Colors.red, context),
      _kartica('%', 'Razmerje pozitivnih primerov in testov:',
          getTestsRatio(podatki), Colors.blueGrey[700], context),
      _kartica('', 'Dnevno število umrlih oseb:', getDeceased(podatki),
          Colors.black, context),
      _kartica('', 'Skupno število hospitaliziranih oseb na posamezen dan:',
          getInHospital(podatki), Colors.blue, context),
      _kartica('', 'Skupno število oseb na intenzivni negi na posamezen dan:',
          getInICU(podatki), Colors.yellow[800], context),
      _kartica('', 'Dnevno število odpuščenih oseb iz bolnišnice:',
          getOutOfHospital(podatki), Colors.pink[800], context),
      _kartica('', 'Povprečje potrjenih primerov v zadnjih 7 dneh:',
          get7DaysMean(podatki), Colors.teal, context),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Posodobljeno: " + getDate()),
        ],
      ),
    ]);

List<int> getPerformedTests(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.performedTests);
  return result.toList();
}

List<int> getPositiveTests(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.positiveTests);
  return result.toList();
}

List<int> getDeceased(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.deceased);
  return result.toList();
}

List<int> getInHospital(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.inHospital);
  return result.toList();
}

List<int> getTestsRatio(List<Podatek> podatki) {
  List<int> performed = podatki.map((podatki) => podatki.performedTests).toList();
  List<int> positive = podatki.map((podatki) => podatki.positiveTests).toList();
  List<int> result = [];
  for (int i = 0; i < performed.length; i++) {
    if (performed[i] != null && positive[i] != null) {
      double percent = positive[i]/performed[i];
      percent = percent * 100;
      int f = percent.round();
      result.add(f);
    } else {
      result.add(0);
    }
  }
  return result;
}

List<int> getInICU(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.inICU);
  return result.toList();
}

List<int> getOutOfHospital(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.outOfHospital);
  return result.toList();
}

List<int> get7DaysMean(List<Podatek> podatki) {
  List<int> result = [];

  if (_isInitialized) {
    List<int> mid = (podatki.map((podatki) => podatki.positiveTests)).toList();

    for (int i = 0; i < mid.length; i++) {
      if (mid.elementAt(i) == null) {
        result.add(0);
      } else {
        if (i < 7) {
          result.add(0);
        } else {
          int j = i;
          int k = j - 7;
          int mean = 0;
          while (j > k) {
            if (mid.elementAt(j) != null) {
              mean += (mid.elementAt(j));
            }
            j -= 1;
          }
          mean = mean ~/ 7;
          result.add(mean);
        }
      }
    }
  }

  return result;
}

// ignore: non_constant_identifier_names
int get_seven_days_mean(List<int> podatki, int indeks) {
  if (_isInitialized) {
    if (indeks < 8) {
      return podatki.elementAt(indeks);
    }
    int mean = 0;
    for (int i = podatki.elementAt(indeks) - 1;
        i > podatki.elementAt(indeks) - 8;
        i--) {
      mean += podatki.elementAt(i);
    }
    return mean ~/ 7;
  } else {
    return 0;
  }
}

String getDate() {
  var now = new DateTime.now();
  var nicla = "";
  if (now.minute < 10) {
    nicla = "0";
  }
  return now.day.toString() +
      "." +
      now.month.toString() +
      "." +
      now.year.toString() +
      ", " +
      now.hour.toString() +
      ":" +
      nicla +
      now.minute.toString();
}

Widget _kartica(String dodatek, String naslov, List<int> podatki, Color barva,
        BuildContext context) =>
    Card(
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          naslov,
          style: TextStyle(fontSize: 20, color: barva),
        ),
        subtitle: Text(podatki.last.toString() + dodatek,
            style: TextStyle(fontSize: 35, color: barva)),
        children: <Widget>[
          SfSparkAreaChart(
            marker:
                SparkChartMarker(displayMode: SparkChartMarkerDisplayMode.high),
            color: barva,
            data: podatki.toList(),
            trackball: SparkChartTrackball(
              borderWidth: 1,
              borderColor: barva,
            ),
          )
        ],
      ),
    );
