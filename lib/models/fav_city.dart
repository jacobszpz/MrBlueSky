import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';

class FavCity {
  late City city;
  late double distance;
  DateTime dateAdded = DateTime.now();

  FavCity.fromCities(CityWeather favCity, CityWeather home) {
    distance =
        (favCity.location.coordinates - home.location.coordinates).distance;
    city = favCity.asCity;
  }

  FavCity.justAdded(this.city, this.distance);
  FavCity(this.city, this.distance, this.dateAdded);

  Map<String, dynamic> toMap() {
    return {
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'distance': distance
    };
  }

  factory FavCity.fromMap(String encodedCity, Map<String, dynamic> map) {
    return FavCity(City.fromBase64(encodedCity), map['distance'],
        DateTime.fromMillisecondsSinceEpoch(map['dateAdded']));
  }
}
