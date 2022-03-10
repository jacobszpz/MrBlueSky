class Location {
  String _type = "";
  double _lat = 0;
  double _long = 0;

  double get lat {
    return _lat;
  }

  double get long {
    return _long;
  }
  Location(Map<String, dynamic> location) {
    var coords = location['coordinates'];
    _type = location['type'];
    _lat = coords[0];
    _long = coords[1];
  }

  Location.empty();
}