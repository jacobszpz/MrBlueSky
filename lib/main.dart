import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/views/cities/city_tab.dart';
import 'package:mr_blue_sky/views/drawer.dart';
import 'package:mr_blue_sky/views/notes/create_note.dart';
import 'package:mr_blue_sky/views/notes/note_tab.dart';
import 'package:mr_blue_sky/views/search_delegate.dart';
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
                return const Scaffold(
                    body: Center(
                        child: Text("Firebase could not be initialised")));
              } else if (snapshot.hasData) {
                // Configure Auth providers
                FlutterFireUIAuth.configureProviders([
                  const PhoneProviderConfiguration(),
                  const GoogleProviderConfiguration(clientId: _googleClientId)
                ]);
                return const MyHomePage(title: 'Mr. Blue Sky');
              } else {
                // Display loading indicator
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
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
  List<City> _localCities = [];
  Map<String, bool> _favouriteCities = {};
  List<Note> _notes = [];
  CityWeather _cityWeather = CityWeather.empty();
  bool _shareIcon = true;
  User? _loggedUser;
  final _db = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              "https://mr-bluesky-default-rtdb.europe-west1.firebasedatabase.app/")
      .ref("sharedPrefs");

  static const List<Tab> _homeTabs = <Tab>[
    Tab(text: "WEATHER"),
    Tab(text: "MY CITIES"),
    Tab(text: "MY NOTES"),
  ];

  late TabController _tabController;
  late ScrollController _cityScrollController;

  bool get isLoggedIn {
    return _loggedUser != null;
  }

  String get userUID {
    return _loggedUser?.uid.toString() ?? "";
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

    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      setState(() {
        _loggedUser = userStream;
        if (_loggedUser != null) {
          _fetchNotes();
          _fetchFavouriteCities();
        }
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
  }

  DatabaseReference get userReference {
    return _db.child(userUID);
  }

  DatabaseReference get notesRef {
    return userReference.child('notes');
  }

  DatabaseReference get favCitiesRef {
    return userReference.child('favCities');
  }

  _fetchNotes() {
    _notes.clear();
    notesRef.get().then((snapshot) {
      Object notesObj = snapshot.value ?? <Object, Object>{};
      var notesObjMap = notesObj as Map<Object?, Object?>;
      Map<String, dynamic> dbNotes = notesObjMap.cast<String, dynamic>();

      for (var noteEntry in dbNotes.entries) {
        Map<String, dynamic> noteMap = noteEntry.value.cast<String, dynamic>();
        _notes.add(Note.fromRTDB(noteEntry.key, noteMap));
      }
    });
  }

  _fetchFavouriteCities() {
    _favouriteCities.clear();
    favCitiesRef.get().then((snapshot) {
      Object favCitiesObj = snapshot.value ?? <Object, Object>{};
      var citiesObjMap = favCitiesObj as Map<Object?, Object?>;
      Map<String, bool> dbCities = citiesObjMap.cast<String, bool>();
      _favouriteCities.addAll(dbCities);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _onSearchTap() {
    showSearch(context: context, delegate: CitySearchDelegate(api: _airAPI))
        .then((result) {
      if (result != null) {
        openCityWeather(result);
      }
    });
  }

  _removeNote(int index) {
    if (index < _notes.length) {
      var note = _notes.elementAt(index);
      if (_loggedUser != null) {
        notesRef.child(note.uuid).remove();
      }
    }
    _notes.removeAt(index);
  }

  _writeNewNote() async {
    Note newNote =
        await Navigator.of(context).push(createNoteWriterRoute(Note.empty()));
    setState(() {
      if (newNote.isNotEmpty) {
        if (_loggedUser != null) {
          notesRef.child(newNote.uuid).set(newNote.toMap());
        }
        _notes.add(newNote);
      }
    });
    return newNote;
  }

  _editNote(int index) async {
    var newNote = await Navigator.of(context)
        .push(createNoteWriterRoute(_notes.elementAt(index)));
    setState(() {
      notesRef.child(newNote.uuid).set(newNote.toMap());
      _notes[index] = newNote;
    });
    return newNote;
  }

  _addFavouriteCity(City city) {
    setState(() {
      if (_loggedUser != null) {
        favCitiesRef.child(city.toBase64).set(true);
      }
      _favouriteCities[city.toBase64] = true;
    });
  }

  _removeFavouriteCity(City city) {
    setState(() {
      if (_loggedUser != null) {
        favCitiesRef.child(city.toBase64).remove();
      }
      _favouriteCities.remove(city.toBase64);
    });
  }

  _handleFABPress() {
    switch (_tabController.index) {
      case 0:
        Share.share(_cityWeather.getShareMsg);
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
        appBar: AppBar(
          title: Text('Weather at ${cityWeather.city}'),
          actions: <Widget>[
            IconButton(
                onPressed: (() {
                  Share.share(cityWeather.getShareMsg);
                }),
                icon: const Icon(Icons.share))
          ],
        ),
        body: WeatherTab(cityWeather: cityWeather));
  }

  openCityWeather(City city) {
    _airAPI.getWeatherFromCity(city).then((cityWeather) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => _weatherTabWrapper(cityWeather)),
      );
    });
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
              tooltip: 'Search city',
              onPressed: () {
                _onSearchTap();
              },
            ),
          ]),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          WeatherTab(cityWeather: _cityWeather),
          CityTab(
            cities: _localCities,
            favCities: _favouriteCities,
            controller: _cityScrollController,
            onTap: ((index) {
              openCityWeather(_localCities.elementAt(index));
            }),
            onFavTap: ((index, favourite) {
              if (favourite) {
                _addFavouriteCity(_localCities.elementAt(index));
              } else {
                _removeFavouriteCity(_localCities.elementAt(index));
              }
            }),
          ),
          NoteTab(
            notes: _notes,
            onTap: (int index) {
              _editNote(index);
            },
            onDismissed: ((int index) {
              _removeNote(index);
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
