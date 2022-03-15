import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/state.dart' as iq_state;
import 'package:mr_blue_sky/api/weather_api.dart';
import 'package:mr_blue_sky/db/countries.dart';

enum SearchState { country, state, city }

class LocationChip {
  String msg;
  SearchState type;

  LocationChip(this.msg, this.type);
}

class CitySearchDelegate extends SearchDelegate {
  List<LocationChip> chips = [];
  List<String> locationItems = [];
  WeatherAPI api;
  var searchState = SearchState.country;

  @override
  String? get searchFieldLabel => "Search a city...";

  CitySearchDelegate({required this.api});

  Future<List<String>> _fetchCountries() async {
    List<String> countries = [];
    // Open country database
    var countriesDb = CountriesProvider();
    await countriesDb.open();

    // Fetch db entries
    countries = await countriesDb.getAll();

    // If db is empty, fetch from API
    if (countries.isEmpty) {
      try {
        countries = await api.getCountries();
      } catch (e) {
        return Future.error(e.toString());
      }
      countriesDb.insertCountries(countries);
    }

    return countries;
  }

  Future<List<iq_state.State>> _fetchStates(String country) async {
    List<iq_state.State> states = [];
    if (states.isEmpty) {
      try {
        states = await api.getStates(country);
      } catch (e) {
        return Future.error(e.toString());
      }
    }
    return states;
  }

  Future<List<City>> _fetchCities(String country, String state) async {
    List<City> cities = [];
    if (cities.isEmpty) {
      cities = await api.getCities(country, state);
    }
    return cities;
  }

  _deleteChip(LocationChip chip) {
    searchState = chip.type;

    if (chip.type == SearchState.country) {
      chips.clear();
      locationItems.clear();
    }

    if (chip.type == SearchState.state) {
      chips.removeLast();
      locationItems.removeLast();
    }
  }

  Widget _chippyRow(List<LocationChip> chips, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          for (var chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Chip(
                label: Text(chip.msg),
                onDeleted: (() {
                  setState(() {
                    _deleteChip(chip);
                  });
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchListItem(String displayName, {Function()? onTap}) {
    return ListTile(
      onTap: (() {
        onTap!();
      }),
      title: Text(displayName),
    );
  }

  Widget apiErrorWidget() {
    return const Center(child: Text("No items were found."));
  }

  Widget waitingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget dividerWidget() {
    return const Divider(thickness: 2, height: 2);
  }

  _citiesFutureBuilder(BuildContext context, StateSetter setState) {
    return FutureBuilder<List<City>>(
        future: _fetchCities(locationItems.first, locationItems.last),
        builder: (BuildContext context, AsyncSnapshot<List<City>> snapshot) {
          List<City> suggestions = [];
          if (snapshot.hasError) {
            return apiErrorWidget();
          } else if (snapshot.hasData) {
            List<City> citiesFetched = snapshot.data ?? [];
            suggestions.addAll(citiesFetched.where((element) {
              return element.city.toLowerCase().contains(query.toLowerCase());
            }));
            return ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: ((context, index) {
                return dividerWidget();
              }),
              itemBuilder: ((context, index) {
                City city = suggestions.elementAt(index);
                return _searchListItem(city.city, onTap: (() {
                  setState(() {
                    close(context, city);
                  });
                }));
              }),
            );
          } else {
            return waitingWidget();
          }
        });
  }

  _statesFutureBuilder(BuildContext context, StateSetter setState) {
    return FutureBuilder<List<iq_state.State>>(
        future: _fetchStates(locationItems.first),
        builder: (BuildContext context,
            AsyncSnapshot<List<iq_state.State>> snapshot) {
          List<iq_state.State> suggestions = [];
          if (snapshot.hasError) {
            return apiErrorWidget();
          } else if (snapshot.hasData) {
            List<iq_state.State> statesFetched = snapshot.data ?? [];
            suggestions.addAll(statesFetched.where((element) {
              return element.state.toLowerCase().contains(query.toLowerCase());
            }));
            return ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: ((context, index) {
                return dividerWidget();
              }),
              itemBuilder: ((context, index) {
                iq_state.State state = suggestions.elementAt(index);
                return _searchListItem(state.state, onTap: (() {
                  setState(() {
                    locationItems.add(state.state);
                    searchState = SearchState.city;
                    chips.add(LocationChip(state.state, SearchState.state));
                    query = "";
                  });
                }));
              }),
            );
          } else {
            return waitingWidget();
          }
        });
  }

  _countriesFutureBuilder(BuildContext context, StateSetter setState) {
    return FutureBuilder<List<String>>(
        future: _fetchCountries(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          List<String> suggestions = [];
          if (snapshot.hasError) {
            return apiErrorWidget();
          } else if (snapshot.hasData) {
            List<String> countriesFetched = snapshot.data ?? [];
            suggestions.addAll(countriesFetched.where((element) =>
                element.toLowerCase().contains(query.toLowerCase())));
            return ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: ((context, index) {
                return dividerWidget();
              }),
              itemBuilder: ((context, index) {
                String country = suggestions.elementAt(index);
                return _searchListItem(country, onTap: (() {
                  setState(() {
                    locationItems.add(country);
                    searchState = SearchState.state;
                    chips.add(LocationChip(country, SearchState.country));
                    query = "";
                  });
                }));
              }),
            );
          } else {
            return waitingWidget();
          }
        });
  }

  FutureBuilder _futureBuilder(BuildContext context, StateSetter setState) {
    switch (searchState) {
      case SearchState.country:
        return _countriesFutureBuilder(context, setState);
      case SearchState.state:
        return _statesFutureBuilder(context, setState);
      case SearchState.city:
        return _citiesFutureBuilder(context, setState);
    }
  }

  StatefulBuilder resultsWidget(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(
        children: [
          // Chippy row
          _chippyRow(chips, setState),
          Expanded(
              // Countries Future Builder
              child: _futureBuilder(context, setState))
        ],
      );
    });
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (() {
          Navigator.pop(context);
        }));
  }

  @override
  Widget buildResults(BuildContext context) {
    return resultsWidget(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return resultsWidget(context);
  }
}
