import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/db/countries.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/widgets/cities/city_tab.dart';
import 'package:mr_blue_sky/widgets/drawer.dart';
import 'package:mr_blue_sky/widgets/notes/create_note.dart';
import 'package:mr_blue_sky/widgets/notes/note_tab.dart';
import 'package:mr_blue_sky/widgets/weather/weather_tab.dart';
import 'package:share_plus/share_plus.dart';

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
      home: const MyHomePage(title: 'Mr. Blue Sky'),
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
  final IQAir _airAPI = IQAir();
  List<String> _countries = [];
  final List<Note> _notes = [];
  bool _shareIcon = true;

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
    _tabController.addListener(() {
      setState(() {
        _shareIcon = (_tabController.index == 0);
      });
    });
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

  _writeNewNote() async {
    Note newNote =
        await Navigator.of(context).push(createNoteWriterRoute(Note.empty()));
    setState(() {
      if (newNote.isNotEmpty) {
        _notes.add(newNote);
      }
    });
    return newNote;
  }

  _editNote(int index) async {
    var newNote = await Navigator.of(context)
        .push(createNoteWriterRoute(_notes.elementAt(index)));
    setState(() {
      _notes[index] = newNote;
    });
    return newNote;
  }

  _handleFABPress() {
    switch (_tabController.index) {
      case 0:
        Share.share(
            'The weather in Preston, UK is 10 celsius. https://google.com');
        break;
      case 1:
        break;
      case 2:
        _writeNewNote();
        break;
      default:
        break;
    }
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
        children: <Widget>[
          WeatherTab(),
          CityTab(),
          NoteTab(
            notes: _notes,
            onTap: (int index) {
              _editNote(index);
            },
            onDismissed: ((int index) {
              if (index < _notes.length) {
                _notes.removeAt(index);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _handleFABPress,
          tooltip: 'Add item',
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            firstChild: const Icon(Icons.share),
            secondChild: const Icon(Icons.add),
            crossFadeState: _shareIcon
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          )),
    );
  }
}
