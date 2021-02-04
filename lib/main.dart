import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'API.dart';
import 'Podatki.dart';

bool _isInitialized = false;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        body: _listIzKartic(podatki),
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

Widget _listIzKartic(List<Podatek> podatki) => ListView(children: [
      _kartica('Dnevno število testiranj:', podatki.last.performedTests,
          Colors.green),
      _kartica(
          'Dnevno število pozitivnih:', podatki.last.positiveTests, Colors.red),
      _kartica(
          'Dnevno število umrlih oseb:', podatki.last.deceased, Colors.black),
      _kartica('Skupno število hospitaliziranih oseb na posamezen dan:',
          podatki.last.inHospital, Colors.blue),
      _kartica('Skupno število oseb na intenzivni negi na posamezen dan:',
          podatki.last.inICU, Colors.yellow[800]),
      _kartica('Dnevno število odpuščenih oseb iz bolnišnice:',
          podatki.last.outOfHospital, Colors.pink[800]),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Posodobljeno: " + getDate()),
        ],
      )
    ]);

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

Widget _kartica(String naslov, int stevilo, Color barva) => Card(
      elevation: 3,
      child: Column(children: [
        Align(
          child: Text(
            naslov,
            style: TextStyle(fontSize: 20, color: barva),
          ),
        ),
        Align(
          child: Text(stevilo.toString(),
              style: TextStyle(fontSize: 35, color: barva)),
        )
      ]),
    );
