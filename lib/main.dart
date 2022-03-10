import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/db/countries.dart';
import 'package:mr_blue_sky/widgets/cities/city_container.dart';
import 'package:mr_blue_sky/widgets/drawer.dart';
import 'package:mr_blue_sky/widgets/notes/create_note.dart';
import 'package:mr_blue_sky/widgets/notes/note_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          // Global Text Style
          textTheme: const TextTheme(
              /* headline1: TextStyle(
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cutive',
          ),
          headline6: TextStyle(fontSize: 36.0),
          bodyText2: TextStyle(fontSize: 14.0),*/
              )),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  final IQAir _airAPI = IQAir();
  List<String> _countries = [];
  List<String> _notes = [];

  static const List<Tab> _homeTabs = <Tab>[
    Tab(text: "WEATHER"),
    Tab(text: "CITIES"),
    Tab(text: "NOTES"),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _homeTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    var countriesDb = CountriesProvider();
    await countriesDb.open();

    _countries = await countriesDb.getAll();

    if (_countries.isEmpty) {
      _countries = await _airAPI.getCountries();
      countriesDb.insertCountries(_countries);
    }
  }

  void _handleFABPress() {
    setState(() {
      if (_tabController.index == 2) {
        log("pushing");
        Navigator.of(context).push(createNoteWriterRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyAppDrawer(title: widget.title),
      appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            controller: _tabController,
            tabs: _homeTabs,
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
          ]),
      body: TabBarView(
        controller: _tabController,
        children: [
          Icon(Icons.directions_car),
          ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              CityContainer(title: "Preston, England"),
              CityContainer(title: "Manchester, England"),
              CityContainer(title: "London, England")
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              NoteContainer(title: "Preston, England"),
              NoteContainer(title: "Manchester, England"),
              NoteContainer(title: "London, England")
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
        onPressed: _handleFABPress,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
