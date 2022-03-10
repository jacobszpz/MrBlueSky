import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mr_blue_sky/db/countries.dart';
import 'package:mr_blue_sky/iqair/api.dart';
import 'package:mr_blue_sky/iqair/city_weather.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Perform App setup
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _NoteContainer extends StatefulWidget {
  const _NoteContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<_NoteContainer> createState() => _NoteContainerState();
}

class _NoteContainerState extends State<_NoteContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.amber[100],
      child: Center(child: Text(widget.title)),
    );
  }
}


class _CityContainer extends StatefulWidget {
  const _CityContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<_CityContainer> createState() => _CityContainerState();
}

class _CityContainerState extends State<_CityContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.amber[100],
      child: Center(child: Text(widget.title)),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final IQAir _airAPI = IQAir();
  List<String> _countries = [];
  List<String> _notes = [];

  Future<void> _fetchCountries() async {
    var countriesDb = CountriesProvider();
    await countriesDb.open();

    _countries = await countriesDb.getAll();

    if (_countries.isEmpty) {
      _countries = await _airAPI.getCountries();
      countriesDb.insertCountries(_countries);
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      _fetchCountries().then((value) => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Mr Blue Sky'),
              ),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
                tabs: [
                  Tab(text: "WEATHER"),
                  Tab(text: "CITIES"),
                  Tab(text: "NOTES"),
                ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
              },
            ),
          ]
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.directions_transit),
            ListView(
              padding: const EdgeInsets.all(0),
              children: <Widget>[
                _NoteContainer(title:"Preston, England"),
                _NoteContainer(title:"Manchester, England"),
                _NoteContainer(title:"London, England")
              ],
            )
           /* _notes.isNotEmpty
                ? ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _notes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    child: Center(child: Text('Entry')),
                  );
                }
                ) : const Center(child: Text("Try adding a note :)")),*/
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
