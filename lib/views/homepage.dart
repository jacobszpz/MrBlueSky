import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/iqair/exceptions.dart';
import 'package:mr_blue_sky/api/iqair/weather.dart';
import 'package:mr_blue_sky/api/weather_api.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';
import 'package:mr_blue_sky/providers/fav_cities_provider.dart';
import 'package:mr_blue_sky/providers/notes_provider.dart';
import 'package:mr_blue_sky/providers/weather_provider.dart';
import 'package:mr_blue_sky/views/appbar.dart';
import 'package:mr_blue_sky/views/cities/city_tab.dart';
import 'package:mr_blue_sky/views/drawer.dart';
import 'package:mr_blue_sky/views/fab.dart';
import 'package:mr_blue_sky/views/my_snackbars.dart';
import 'package:mr_blue_sky/views/notes/note_tab.dart';
import 'package:mr_blue_sky/views/search_delegate.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';
import 'package:mr_blue_sky/views/weather/weather_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'notes/create_note.dart';

/// Widget containing the main screen of the app
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Stores the state for the HomePage
class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _showShareFab = true;
  bool _showFab = true;

  late TabController _tabController;
  late ScrollController _cityScrollController;
  late ScrollController _weatherScrollController;

  /// Initialise controllers and add listeners
  @override
  void initState() {
    super.initState();
    _cityScrollController = ScrollController();
    _weatherScrollController = ScrollController();

    _tabController = TabController(vsync: this, length: MyAppBar.tabs.length);
    _tabController.addListener(() {
      setState(() {
        // Show share icon only on first tab
        _showShareFab = (_tabController.index == 0);
        // Show FAB on tab change
        _showFab = true;
      });
    });

    // Hide FAB when scrolling down on weather tab
    _weatherScrollController.addListener(() {
      _setFabOpacityOnScroll();
    });

    // Handle network errors with weather provider
    Future<CityWeather> weatherFuture =
        Provider.of<WeatherProvider>(context, listen: false).weatherFuture;

    // Show appropriate SnackBar
    weatherFuture.then((value) => null).onError((error, stackTrace) {
      _showSnackBar(MySnackBars.rateIssue());
    }, test: (e) => e is ApiException).catchError((error, stackTrace) {
      _showSnackBar(MySnackBars.networkIssue());
    });
  }

  _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Changes FAB opacity depending on weather tab scroll direction
  _setFabOpacityOnScroll() {
    ScrollDirection userScrollDirection =
        _weatherScrollController.position.userScrollDirection;

    bool _fabVisible = _showFab;
    if (userScrollDirection == ScrollDirection.forward) {
      _fabVisible = true;
    } else if (userScrollDirection == ScrollDirection.reverse) {
      _fabVisible = false;
    }

    if (_showFab != _fabVisible) {
      setState(() {
        _showFab = _fabVisible;
      });
    }
  }

  /// Handle taps in the TabBar
  _onTabBarTap(int index) {
    if (index == 1) {
      if (!_tabController.indexIsChanging) {
        _cityScrollController.animateTo(
            _cityScrollController.initialScrollOffset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.ease);
      }
    }
  }

  /// Dispose of controllers
  @override
  void dispose() {
    _tabController.dispose();
    _cityScrollController.dispose();
    _weatherScrollController.dispose();
    super.dispose();
  }

  /// Show search delegate
  _onSearch() {
    showSearch(context: context, delegate: CitySearchDelegate()).then((result) {
      if (result != null) {
        bool isFavourite =
            Provider.of<FavCitiesProvider>(context, listen: false)
                .favourites
                .contains(result);
        _openCityWeather(result, isFavourite);
      }
    });
  }

  /// Open note writer to create new note
  _writeNewNote() async {
    Weather? weather = context.read<WeatherProvider>().cityWeather?.weather;
    WeatherType noteWeatherType = weather?.type ?? WeatherType.clearSkyDay;
    Note note = await Navigator.of(context)
        .push(createNoteWriterRoute(Note.fromWeather(noteWeatherType)));
    Provider.of<NotesProvider>(context, listen: false).add(note);
    return note;
  }

  /// Open note writer with existing note and update provider
  _editNote(int index) async {
    var notes = context.read<NotesProvider>().notes;
    Provider.of<NotesProvider>(context, listen: false).edit(
        index,
        await Navigator.of(context)
            .push(createNoteWriterRoute(notes.elementAt(index))));
  }

  /// Handle FAB press
  _onFabPress() {
    switch (_tabController.index) {
      // Share weather info
      case 0:
        final cityWeather = context.read<WeatherProvider>().cityWeather;
        if (cityWeather == null) {
          _showSnackBar(MySnackBars.weatherNotReady());
        } else {
          Share.share(cityWeather.getShareMsg);
        }
        break;

      // Open city search
      case 1:
        _onSearch();
        break;

      // Open note writer
      case 2:
        _writeNewNote();
        break;
    }
  }

  /// Open weather overview for a given city
  _openCityWeather(City city, bool fav) async {
    WeatherAPI api = context.read<WeatherProvider>().api;
    api.getWeatherFromCity(city).then((cityWeather) {
      var favProvider = Provider.of<FavCitiesProvider>(context, listen: false);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WeatherWrapper(
                  cityWeather: cityWeather,
                  favourite: fav,
                  onFavTap: ((bool fav) {
                    if (fav) {
                      favProvider.add(cityWeather);
                    } else {
                      favProvider.remove(cityWeather.asCity);
                    }
                  }),
                )),
      );
    }).onError((error, stackTrace) {
      _showSnackBar(MySnackBars.rateIssue());
    }, test: (e) => e is ApiException).catchError((error, stackTrace) {
      _showSnackBar(MySnackBars.networkIssue());
    });
  }

  /// Sort listviews by chosen criteria
  _onSort(SortingOrder order, int tabIndex) {
    if (tabIndex == 1) {
      final cityWeather = context.read<WeatherProvider>().cityWeather;
      if (order == SortingOrder.distance && cityWeather == null) {
        _showSnackBar(MySnackBars.weatherNotReady());
      } else {
        Provider.of<FavCitiesProvider>(context, listen: false)
            .sort(order, cityWeather?.location.coordinates);
      }
    }
    if (tabIndex == 2) {
      Provider.of<NotesProvider>(context, listen: false).sort(order);
    }
  }

  /// Build the Mr. Blue Sky Home Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const MyAppDrawer(),
        appBar: MyAppBar(
          title: widget.title,
          tabController: _tabController,
          onSort: (order) => _onSort(order, _tabController.index),
          onSearch: () => _onSearch(),
          onTabBarTap: (index) => _onTabBarTap(index),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Consumer<WeatherProvider>(
              builder: (builder, model, child) {
                return WeatherTab(
                    cityWeather: model.cityWeather,
                    scrollController: _weatherScrollController);
              },
            ),
            Consumer<FavCitiesProvider>(builder: (builder, model, child) {
              return CityTab(
                controller: _cityScrollController,
                onTap: ((index) {
                  _openCityWeather(
                      model.favourites.elementAt(index).city, true);
                }),
                onFavTap: ((index) {
                  model.removeAt(index);
                }),
                cities: model.favourites,
              );
            }),
            Consumer<NotesProvider>(builder: (builder, model, child) {
              return NoteTab(
                  notes: model.notes,
                  onTap: (int index) {
                    _editNote(index);
                  },
                  onDismissed: ((int index) {
                    model.removeAt(index);
                  }));
            })

            //),
          ],
        ),
        floatingActionButton: MyFloatingActionButton(
          showFab: _showFab,
          showShareIcon: _showShareFab,
          onFabPress: () => _onFabPress(),
        ));
  }
}
