import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/db/fav_cities.dart';
import 'package:mr_blue_sky/firebase/values.dart';
import 'package:mr_blue_sky/models/coords.dart';
import 'package:mr_blue_sky/models/fav_city.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';

class FavCitiesProvider extends ChangeNotifier {
  final List<FavCity> _favouriteCities = [];
  User? firebaseUser;
  late Future openDB;

  final FavCitiesSQLite _sqlDB = FavCitiesSQLite();
  final _db =
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: dbURL)
          .ref();

  static const favCitiesPath = 'favCities';

  FavCitiesProvider() {
    openDB = _sqlDB.open();
    _getFromLocal().then((value) => notifyListeners());
    _listenToFavourites();
  }

  Future _getFromLocal() async {
    await openDB;
    _sqlDB.getAll().then((sqlFavs) {
      _favouriteCities.addAll(sqlFavs);
    });
  }

  late StreamSubscription<DatabaseEvent> _favStream;

  List<FavCity> get favourites => _favouriteCities;

  DatabaseReference _favRef(String userUID) {
    return _db.child(sharedPrefsPath).child(userUID).child(favCitiesPath);
  }

  _listenToFavourites() {
    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      firebaseUser = userStream;

      if (userStream == null) {
        _favStream.cancel();
      } else {
        _favStream = _favRef(userStream.uid).onValue.listen((event) {
          _favouriteCities.clear();
          _favouriteCities.addAll(_getFromSnapshot(event.snapshot));
          notifyListeners();
        });

        openDB.then((_) {
          _sqlDB.getAll().then((favCities) {
            for (FavCity fav in favCities) {
              _favRef(userStream.uid).child(fav.city.toBase64).set(fav.toMap());
              _sqlDB.clear();
            }
          });
        });
      }
    });
  }

  List<FavCity> _getFromSnapshot(DataSnapshot snapshot) {
    List<FavCity> favourites = [];
    Object favCitiesObj = snapshot.value ?? <Object, Object>{};
    var citiesObjMap = favCitiesObj as Map<Object?, Object?>;
    Map<String, dynamic> dbCities = citiesObjMap.cast<String, dynamic>();

    for (var cityEntry in dbCities.entries) {
      Map<String, dynamic> cityMap = cityEntry.value.cast<String, dynamic>();
      favourites.add(FavCity.fromMap(cityEntry.key, cityMap));
    }

    favourites.sort(((a, b) => a.dateAdded.compareTo(b.dateAdded)));

    return favourites;
  }

  removeAt(int index) {
    FavCity deleted = _favouriteCities.removeAt(index);
    final user = firebaseUser;

    if (user != null) {
      _favRef(user.uid).child(deleted.city.toBase64).remove();
    } else {
      _sqlDB.delete(deleted.city.toBase64);
    }

    notifyListeners();
  }

  remove(City city) {
    final user = firebaseUser;

    if (user != null) {
      _favRef(user.uid).child(city.toBase64).remove();
    } else {
      _sqlDB.delete(city.toBase64);
    }

    _favouriteCities.removeWhere((element) => element.city == city);
    notifyListeners();
  }

  add(CityWeather cityWeather) {
    FavCity fav =
        FavCity.justAdded(cityWeather.asCity, cityWeather.location.coordinates);

    final user = firebaseUser;
    if (user != null) {
      _favRef(user.uid).child(fav.city.toBase64).set(fav.toMap());
    } else {
      _sqlDB.insertCity(fav);
    }

    _favouriteCities.add(fav);
    notifyListeners();
  }

  sort(SortingOrder order, [Coordinates? measureDistanceAgainst]) async {
    int Function(FavCity a, FavCity b) sortingFunction =
        ((a, b) => a.dateAdded.compareTo(b.dateAdded));

    if (order == SortingOrder.alphabet) {
      sortingFunction = ((a, b) => a.city.country.compareTo(b.city.country));
    } else if (order == SortingOrder.distance) {
      if (measureDistanceAgainst != null) {
        sortingFunction = ((a, b) {
          Coordinates lineA = a.location - measureDistanceAgainst;
          Coordinates lineB = b.location - measureDistanceAgainst;
          return lineA.distance.compareTo(lineB.distance);
        });
      }
    }
    _favouriteCities.sort(sortingFunction);
    notifyListeners();
  }

  @override
  void dispose() {
    _favStream.cancel();
    super.dispose();
  }
}
