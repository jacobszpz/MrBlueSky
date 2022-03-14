import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:mr_blue_sky/api/iqair/state.dart';

abstract class WeatherAPI {
  Future<List<String>> getCountries();
  Future<List<State>> getStates(String country);
  Future<List<City>> getCities(String country, String state);
}
