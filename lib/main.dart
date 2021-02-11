import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
      _kartica('Dnevno število testiranj PCR:', getPerformedTests(podatki),
          Colors.green, context),
      _kartica('Dnevno število potrjenih primerov:', getPositiveTests(podatki),
          Colors.red, context),
      _kartica('Dnevno število umrlih oseb:', getDeceased(podatki),
          Colors.black, context),
      _kartica('Skupno število hospitaliziranih oseb na posamezen dan:',
          getInHospital(podatki), Colors.blue, context),
      _kartica('Skupno število oseb na intenzivni negi na posamezen dan:',
          getInICU(podatki), Colors.yellow[800], context),
      _kartica('Dnevno število odpuščenih oseb iz bolnišnice:',
          getOutOfHospital(podatki), Colors.pink[800], context),
      _kartica('Povprečje potrjenih primerov v zadnjih 7 dneh:',
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

Iterable<int> getPerformedTests(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.performedTests);
  return result;
}

Iterable<int> getPositiveTests(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.positiveTests);
  return result;
}

Iterable<int> getDeceased(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.deceased);
  return result;
}

Iterable<int> getInHospital(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.inHospital);
  return result;
}

Iterable<int> getInICU(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.inICU);
  return result;
}

Iterable<int> getOutOfHospital(List<Podatek> podatki) {
  var result = podatki.map((podatki) => podatki.outOfHospital);
  return result;
}

Iterable<int> get7DaysMean(List<Podatek> podatki) {
  //TODO: to popravi!!!
  var result = podatki.map((podatki) => podatki.positiveTests);
  var finalList = Iterable.generate(result.length);
  for (int i = 0; i < result.length; i++) {
    // finalList[i] = (get_seven_days_mean(result,i));<w
  }
  return Iterable.castFrom(finalList);
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

Widget _kartica(String naslov, Iterable<int> podatki, Color barva,
        BuildContext context) =>
    Card(
        elevation: 4,
        child: ExpansionTile(
          title: Text(
            naslov,
            style: TextStyle(fontSize: 20, color: barva),
          ),
          subtitle: Text(podatki.last.toString(),
              style: TextStyle(fontSize: 35, color: barva)),
          children: <Widget>[
            SfSparkAreaChart(
              color: barva,
              data: podatki.toList(),
            )
          ],
        ),
      );

Widget _buildNewTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
      reverseCurve: Curves.fastOutSlowIn,
    ),
    child: child,
  );
}
