import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:mr_blue_sky/models/fav_city.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';
import 'package:mr_blue_sky/views/cities/city_tab.dart';
import 'package:mr_blue_sky/views/drawer.dart';
import 'package:mr_blue_sky/views/notes/create_note.dart';
import 'package:mr_blue_sky/views/notes/note_tab.dart';
import 'package:mr_blue_sky/views/search_delegate.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';
import 'package:mr_blue_sky/views/weather/weather_wrapper.dart';
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
    Color? blueSkyColor = Colors.blue[500];
    Color? deepSkyColor = Colors.deepPurple[900];

    return MaterialApp(
        title: 'Flutter Demo',
        darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                    brightness: Brightness.dark,
                    accentColor: deepSkyColor,
                    primaryColorDark: deepSkyColor,
                    primarySwatch: Colors.blue,
                    cardColor: deepSkyColor))
            .copyWith(useMaterial3: true),
        theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                    brightness: Brightness.light,
                    cardColor: blueSkyColor,
                    primaryColorDark: deepSkyColor,
                    primarySwatch: Colors.blue),

                // Global Text Style
                textTheme: const TextTheme(
                    /* headline1: TextStyle(
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cutive',
          ),
          headline6: TextStyle(fontSize: 36.0),
          bodyText2: TextStyle(fontSize: 14.0),*/
                    ))
            .copyWith(useMaterial3: true),
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
                FirebaseDatabase.instance.setPersistenceEnabled(true);
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
  final List<FavCity> _favouriteCities = [];
  final List<Note> _notes = [];
  CityWeather? _cityWeather;
  bool _shareIcon = true;
  User? _loggedUser;
  late StreamSubscription connectivityStream;
  bool isFabVisible = true;
  SortingOrder citySortingOrder = SortingOrder.alphabet;

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
  late ScrollController _weatherScrollController;

  bool get isLoggedIn {
    return _loggedUser != null;
  }

  String get userUID {
    return _loggedUser?.uid.toString() ?? "";
  }

  _fetchWeather() {
    _airAPI.getNearestCityWeather().then((cityWeather) {
      setState(() {
        _cityWeather = cityWeather;
      });
    }).catchError(
      ((event) {
        _showSnackBar(_networkIssue());
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _cityScrollController = ScrollController();
    _weatherScrollController = ScrollController();
    _tabController = TabController(vsync: this, length: _homeTabs.length);
    _tabController.addListener(() {
      setState(() {
        _shareIcon = (_tabController.index == 0);
        isFabVisible = true;
      });
    });

    _weatherScrollController.addListener(() {
      ScrollDirection userScrollDirection =
          _weatherScrollController.position.userScrollDirection;
      setState(() {
        if (userScrollDirection == ScrollDirection.forward) {
          isFabVisible = true;
        } else if (userScrollDirection == ScrollDirection.reverse) {
          isFabVisible = false;
        }
      });
    });

    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      setState(() {
        _loggedUser = userStream;
        if (_loggedUser != null) {
          _activateListeners();
        }
      });
    });

    _fetchWeather();

    connectivityStream = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // If not fetched, try fetching again
      if (_cityWeather == null) {
        _fetchWeather();
      }
    });
  }

  _activateListeners() {
    notesRef.onValue.listen((event) {
      _fetchNotes(event.snapshot);
    });

    favCitiesRef.onValue.listen((event) {
      _fetchFavouriteCities(event.snapshot);
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

  _fetchNotes(DataSnapshot snapshot) {
    _notes.clear();
    Object notesObj = snapshot.value ?? <Object, Object>{};
    var notesObjMap = notesObj as Map<Object?, Object?>;
    Map<String, dynamic> dbNotes = notesObjMap.cast<String, dynamic>();

    for (var noteEntry in dbNotes.entries) {
      Map<String, dynamic> noteMap = noteEntry.value.cast<String, dynamic>();
      _notes.add(Note.fromRTDB(noteEntry.key, noteMap));
    }

    setState(() {
      _notes
          .sort(((a, b) => a.creationTimestamp.compareTo(b.creationTimestamp)));
    });
  }

  _fetchFavouriteCities(DataSnapshot snapshot) {
    _favouriteCities.clear();
    Object favCitiesObj = snapshot.value ?? <Object, Object>{};
    var citiesObjMap = favCitiesObj as Map<Object?, Object?>;
    Map<String, dynamic> dbCities = citiesObjMap.cast<String, dynamic>();

    for (var cityEntry in dbCities.entries) {
      Map<String, dynamic> cityMap = cityEntry.value.cast<String, dynamic>();
      _favouriteCities.add(FavCity.fromMap(cityEntry.key, cityMap));
    }

    setState(() {
      _favouriteCities.sort(((a, b) => a.dateAdded.compareTo(b.dateAdded)));
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
        openCityWeather(result, _favouriteCities.contains(result));
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
    WeatherType noteWeatherType =
        _cityWeather?.weather.type ?? WeatherType.clearSkyDay;
    Note newNote = await Navigator.of(context)
        .push(createNoteWriterRoute(Note.fromWeather(noteWeatherType)));
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

  _addFavouriteCity(CityWeather city) {
    FavCity fav = FavCity.fromCities(city, _cityWeather ?? CityWeather.empty());
    setState(() {
      if (_loggedUser != null) {
        favCitiesRef.child(city.asCity.toBase64).set(fav.toMap());
      }
      _favouriteCities.add(fav);
    });
  }

  _removeFavouriteCityByIndex(int index) {
    setState(() {
      FavCity deleted = _favouriteCities.removeAt(index);

      if (_loggedUser != null) {
        favCitiesRef.child(deleted.city.toBase64).remove();
      }
    });
  }

  _removeFavouriteCity(City city) {
    setState(() {
      if (_loggedUser != null) {
        favCitiesRef.child(city.toBase64).remove();
      }
      _favouriteCities.removeWhere((element) => element.city == city);
    });
  }

  SnackBar _weatherNotReady() {
    return const SnackBar(
      content: Text('Weather data not ready'),
    );
  }

  SnackBar _networkIssue() {
    return const SnackBar(
      content: Text('The weather API could not be reached'),
    );
  }

  _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _handleFABPress() {
    switch (_tabController.index) {
      case 0:
        if (_cityWeather == null) {
          _showSnackBar(_weatherNotReady());
        } else {
          Share.share(_cityWeather?.getShareMsg ?? "");
        }
        break;
      case 1:
        _onSearchTap();
        break;
      case 2:
        _writeNewNote();
        break;
      default:
        break;
    }
  }

  openCityWeather(City city, bool fav) {
    _airAPI.getWeatherFromCity(city).then((cityWeather) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WeatherWrapper(
                  weather: cityWeather,
                  favourite: fav,
                  onShare: (() {
                    Share.share(cityWeather.getShareMsg);
                  }),
                  onFavTap: ((bool fav) {
                    if (fav) {
                      _addFavouriteCity(cityWeather);
                    } else {
                      _removeFavouriteCity(cityWeather.asCity);
                    }
                  }),
                )),
      ).then((value) {});
    }).catchError((Object obj, StackTrace trace) {
      log(trace.toString());
      _showSnackBar(_networkIssue());
    });
  }

  _changeSortingOrder(SortingOrder order, int tabIndex) {
    if (tabIndex == 2) {
      if (order == SortingOrder.time) {
        setState(() {
          _notes.sort(
              ((a, b) => a.creationTimestamp.compareTo(b.creationTimestamp)));
        });
      } else if (order == SortingOrder.alphabet) {
        setState(() {
          _notes.sort(((a, b) => a.title.compareTo(b.title)));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 200);
    ThemeData theme = Theme.of(context);

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
              indicatorColor: theme.colorScheme.secondary,
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
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: (_tabController.index != 0) ? 1 : 0,
                child: PopupMenuButton(
                    icon: Icon(Icons.sort, color: theme.canvasColor),
                    onSelected: ((SortingOrder order) {
                      _changeSortingOrder(order, _tabController.index);
                    }),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuItem<SortingOrder>>[
                        const PopupMenuItem(
                          child: Text('Alphabetically'),
                          value: SortingOrder.alphabet,
                        ),
                        const PopupMenuItem(
                          child: Text('Date Added'),
                          value: SortingOrder.time,
                        ),
                        if (_tabController.index == 1)
                          const PopupMenuItem(
                            child: Text('Distance'),
                            value: SortingOrder.distance,
                          )
                      ];
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search city',
                onPressed: () {
                  _onSearchTap();
                },
              )
            ]),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            WeatherTab(
                cityWeather: _cityWeather,
                scrollController: _weatherScrollController),
            CityTab(
                cities: _favouriteCities,
                controller: _cityScrollController,
                onTap: ((index) {
                  openCityWeather(_favouriteCities.elementAt(index).city, true);
                }),
                onFavTap: ((index) {
                  _removeFavouriteCityByIndex(index);
                })),
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
        floatingActionButton: AnimatedSlide(
            duration: duration,
            offset: isFabVisible ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: duration,
              opacity: isFabVisible ? 1 : 0,
              child: FloatingActionButton(
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
            )));
  }
}
