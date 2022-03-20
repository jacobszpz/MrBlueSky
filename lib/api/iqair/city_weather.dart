import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/api/iqair/pollution.dart';
import 'package:mr_blue_sky/api/iqair/weather.dart';
import 'package:mr_blue_sky/api/location.dart';
import 'package:mr_blue_sky/api/state.dart';

class CityWeather {
  String city = "";
  String state = "";
  String country = "";
  Location location = Location.empty();
  Weather weather = Weather.empty();
  Pollution pollution = Pollution.empty();

  CityWeather(Map<String, dynamic> cityData) {
    city = cityData['city'];
    state = cityData['state'];
    country = cityData['country'];
    location = Location(cityData['location']);
    var currentForecast = cityData['current'];
    weather = Weather(currentForecast['weather']);
    pollution = Pollution(currentForecast['pollution']);
  }

  CityWeather.empty();

  @override
  String toString() {
    return 'Weather in $city, $country';
  }

  String get getShareMsg {
    return "Hi, I'm in $city, $country, and it's ${weather.temperature} celsius!.";
  }

  State get asState {
    return State(country, state);
  }

  City get asCity {
    return City(country, state, city);
  }
}
