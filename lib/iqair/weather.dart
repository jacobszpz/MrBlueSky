import 'package:mr_blue_sky/iqair/location.dart';

class CityWeather {
  String _city = "";
  String _state = "";
  String _country = "";
  Location _location = Location.n();

  CityWeather(dynamic json) {
    _city = json['city'];
    _state = json['state'];
    _country = json['country'];

    var loc = json['location'];
    var coords = loc['coordinates'];
    _location = Location(loc['type'], coords[0], coords[1]);
  }

  @override
  String toString() {
    return 'Weather in $_city, $_country';
  }
}