import 'package:mr_blue_sky/api/iqair/location.dart';
import 'package:mr_blue_sky/api/iqair/pollution.dart';
import 'package:mr_blue_sky/api/iqair/weather.dart';

class CityWeather {
  String _city = "";
  String _state = "";
  String _country = "";
  Location _location = Location.empty();
  Weather _weather = Weather.empty();
  Pollution _pollution = Pollution.empty();

  CityWeather(Map<String, dynamic> cityData) {
    _city = cityData['city'];
    _state = cityData['state'];
    _country = cityData['country'];
    _location = Location(cityData['location']);
    var currentForecast = cityData['current'];
    _weather = Weather(currentForecast['weather']);
    _pollution = Pollution(currentForecast['pollution']);
  }

  @override
  String toString() {
    return 'Weather in $_city, $_country';
  }
}