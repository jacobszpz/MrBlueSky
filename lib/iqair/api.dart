import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mr_blue_sky/iqair/exceptions.dart';
import 'package:mr_blue_sky/iqair/weather.dart';

/// Get data from the IQAir API
///
/// Available at https://iqair.com
class IQAir {
  /// IQAir base Uri
  final apiUri = Uri(
      scheme: 'http',
      host: 'api.airvisual.com',
      path: '/v2/');

  /// Returns the API key
  String _getKey() {
    return "8cc58d2e-2ed5-4a93-ae15-fd7245e7357c";
  }

  Uri _getAPIUrl(String endpoint, [Map<String, String>? params]) {
    params ??= {};

    var requestParams = {'key': _getKey()};
    requestParams.addAll(params);

    return apiUri.replace(
        path: "${apiUri.path}$endpoint",
        queryParameters: requestParams
    );
  }

  Future<dynamic> _getAPIData(String endpoint, [Map<String, String>? params]) async {
    var endpointUri = _getAPIUrl(endpoint, params);
    var response = await http.get(endpointUri);
    var jsonResponse = jsonDecode(response.body);
    String status = jsonResponse['status'];

    if (status != 'success') {
      throw ApiException();
    }
    var jsonData = jsonResponse['data'];
    return jsonData;
  }

  List<String> _extractItems(dynamic jsonData, String id) {
    List<String> items = [];
    for (var item in jsonData) {
      items.add(item[id]);
    }
    return items;
  }

  /// Returns a list of countries
  Future<List<String>> getCountries() async {
    var jsonData = await _getAPIData("countries");
    return _extractItems(jsonData, "country");
  }

  /// Returns the states which form part of a certain country
  Future<List<String>> getStates(String country) async {
    var jsonData = await _getAPIData("states",
        {'country': country}
    );
    return _extractItems(jsonData, "state");
  }

  /// Returns the cities forming part of the specified state and country
  Future<List<String>> getCities(String country, String state) async {
    var jsonData = await _getAPIData("cities",
        {'country': country, 'state': state}
    );
    return _extractItems(jsonData, "city");
  }

  /// Return the weather in a certain city
  Future<String> getWeather(String country, String state, String city) async {
    var jsonData = await _getAPIData("city",
        {'country': country, 'state': state, 'city': city}
    );

    return jsonData.toString();
  }

  /// Return the weather in a certain city
  Future<CityWeather> getNearestCityWeather() async {
    var jsonData = await _getAPIData("nearest_city");
    return CityWeather(jsonData);
  }

  void test() {
    getWeather("United Kingdom", "England", "Preston").then((String value) {
      log(value);
    });

    getNearestCityWeather().then((CityWeather value) {
      log(value.toString());
    });
  }
}