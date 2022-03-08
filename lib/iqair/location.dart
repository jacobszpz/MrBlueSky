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
  Location(this._type, this._lat, this._long);
  Location.n();
}