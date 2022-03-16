import 'dart:math';

class Coordinates {
  double lat;
  double long;

  Coordinates(this.lat, this.long);

  Coordinates operator -(Coordinates other) {
    return Coordinates(lat - other.lat, long - other.long);
  }

  Coordinates get absolute {
    return Coordinates(lat.abs(), long.abs());
  }

  double get distance {
    return sqrt((lat * lat) + (long * long));
  }
}
