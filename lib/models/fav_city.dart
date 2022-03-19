import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/models/coords.dart';

class FavCityFields {
  static const id = '_id';
  static const hash = 'hash';
  static const dateAdded = 'dateAdded';
  static const lat = 'lat';
  static const long = 'long';
}

class FavCity {
  late City city;
  late Coordinates location;
  DateTime dateAdded = DateTime.now();

  FavCity.justAdded(this.city, this.location);
  FavCity(this.city, this.location, this.dateAdded);

  Map<String, dynamic> toMap() {
    return {
      FavCityFields.dateAdded: dateAdded.millisecondsSinceEpoch,
      FavCityFields.lat: location.lat,
      FavCityFields.long: location.long
    };
  }

  Map<String, dynamic> toDBMap() {
    return {
      FavCityFields.dateAdded: dateAdded.millisecondsSinceEpoch,
      FavCityFields.hash: city.toBase64,
      FavCityFields.lat: location.lat,
      FavCityFields.long: location.long
    };
  }

  factory FavCity.fromMap(String encodedCity, Map<String, dynamic> map) {
    return FavCity(
        City.fromBase64(encodedCity),
        Coordinates(map[FavCityFields.lat], map[FavCityFields.long]),
        DateTime.fromMillisecondsSinceEpoch(map[FavCityFields.dateAdded]));
  }
}
