import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/db/countries.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/views/cities/city_tab.dart';
import 'package:mr_blue_sky/views/drawer.dart';
import 'package:mr_blue_sky/views/notes/create_note.dart';
import 'package:mr_blue_sky/views/notes/note_tab.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();
  static const _googleClientId =
      '852712905855-h9efstsslgre2qvlsrnecn4duk89oatr.apps.googleusercontent.com';

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
        home: FutureBuilder(
            future: _firebaseApp,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                log("Error while initialising Firebase");
                return const Center(
                    child: Text("Error initialising the app :)"));
              } else if (snapshot.hasData) {
                FlutterFireUIAuth.configureProviders([
                  const PhoneProviderConfiguration(),
                  const GoogleProviderConfiguration(clientId: _googleClientId)
                ]);
                return const MyHomePage(title: 'Mr. Blue Sky');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })));
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
  List<City> _localCities = [];
  final List<Note> _notes = [];
  CityWeather _cityWeather = CityWeather.empty();
  bool _shareIcon = true;
  User? _loggedUser;

  static const List<Tab> _homeTabs = <Tab>[
    Tab(text: "WEATHER"),
    Tab(text: "CITIES"),
    Tab(text: "MY NOTES"),
  ];

  late TabController _tabController;
  late ScrollController _cityScrollController;

  bool get isLoggedIn {
    return _loggedUser != null;
  }

  @override
  void initState() {
    super.initState();
    _cityScrollController = ScrollController();
    _tabController = TabController(vsync: this, length: _homeTabs.length);
    _tabController.addListener(() {
      setState(() {
        _shareIcon = (_tabController.index == 0);
      });
    });
    _fetchCountries().then((countries) {
      setState(() {
        _countries = countries;
      });
    });

    _airAPI.getNearestCityWeather().then((cityWeather) {
      // Load cities too
      _airAPI
          .getCities(cityWeather.country, cityWeather.state)
          .then((localCities) {
        setState(() {
          _localCities = localCities;
        });
      });
      setState(() {
        _cityWeather = cityWeather;
      });
    });

    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      setState(() {
        _loggedUser = userStream;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchCountries() async {
    List<String> countries = [];
    // Open country database
    var countriesDb = CountriesProvider();
    await countriesDb.open();

    // Fetch db entries
    countries = await countriesDb.getAll();

    // If db is empty, fetch from API
    if (countries.isEmpty) {
      countries = await _airAPI.getCountries();
      countriesDb.insertCountries(countries);
    }

    return countries;
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
            "Hi, I'm in ${_cityWeather.city}, ${_cityWeather.country}, and it's ${_cityWeather.weather.temperature}° celsius!.");
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

  Widget _weatherTabWrapper(CityWeather cityWeather) {
    return Scaffold(
        appBar: AppBar(title: Text('Weather at ${cityWeather.city}')),
        body: WeatherTab(cityWeather: cityWeather));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyAppDrawer(
        loggedUser: _loggedUser,
        onSignIn: ((context, state) {
          setState(() {
            Navigator.pop(context);
          });
        }),
        onSignOut: ((context) {
          setState(() {
            Navigator.pop(context);
          });
        }),
      ),
      appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            onTap: ((index) {
              switch (index) {
                case 1:
                  if (!_tabController.indexIsChanging) {
                    _cityScrollController.animateTo(
                        _cityScrollController.initialScrollOffset,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.ease);
                  }
                  break;
              }
            }),
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
          WeatherTab(cityWeather: _cityWeather),
          CityTab(
            cities: _localCities,
            controller: _cityScrollController,
            onTap: ((index) {
              _airAPI
                  .getWeatherFromCity(_localCities.elementAt(index))
                  .then((cityWeather) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _weatherTabWrapper(cityWeather)),
                );
              });
            }),
          ),
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
