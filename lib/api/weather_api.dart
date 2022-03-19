import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/state.dart';

abstract class WeatherAPI {
  Future<List<String>> getCountries();
  Future<List<State>> getStates(String country);
  Future<List<City>> getCities(String country, String state);
  Future<CityWeather> getNearestCityWeather();
  Future<List<City>> getCitiesFromState(State state);
  Future<CityWeather> getWeather(String country, String state, String city);
  Future<CityWeather> getWeatherFromCity(City city);
}
