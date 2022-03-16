import 'package:mr_blue_sky/api/iqair/coords.dart';

class Location {
  String _type = "";
  Coordinates _coords = Coordinates(0, 0);

  double get lat {
    return _coords.lat;
  }

  double get long {
    return _coords.long;
  }

  Coordinates get coordinates {
    return _coords;
  }

  Location(Map<String, dynamic> location) {
    var coordsJson = location['coordinates'];
    _type = location['type'];
    _coords = Coordinates(coordsJson[1], coordsJson[0]);
  }

  Location.empty();
}
