import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:mr_blue_sky/api/iqair/api.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/weather_api.dart';

class WeatherProvider extends ChangeNotifier {
  final IQAir _airAPI = IQAir();
  CityWeather? _cityWeather;

  late StreamSubscription<ConnectivityResult> _connectivityStream;
  late Future<CityWeather> _fetchWeatherFuture;

  Future<CityWeather> get weatherFuture => _fetchWeatherFuture;
  CityWeather? get cityWeather => _cityWeather;
  WeatherAPI get api => _airAPI;

  WeatherProvider() {
    _fetch();
    _listenToConnectivity();
  }

  Future _fetch() async {
    _fetchWeatherFuture = _airAPI.getNearestCityWeather();
    try {
      _cityWeather = await _fetchWeatherFuture;
      notifyListeners();
    } catch (error) {
      // Ignore error
    }
  }

  Future _listenToConnectivity() async {
    _connectivityStream = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // If not fetched, try fetching again
      if (_cityWeather == null) {
        _fetch();
      }
    });
  }

  @override
  void dispose() {
    _connectivityStream.cancel();
    super.dispose();
  }
}
