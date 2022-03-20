// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child views in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/iqair/pollution.dart';
import 'package:mr_blue_sky/api/iqair/weather.dart';
import 'package:mr_blue_sky/api/location.dart';
import 'package:mr_blue_sky/api/temperature.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';

import 'weather_tab_test.mocks.dart';

@GenerateMocks([CityWeather, Location, Weather, Temperature, Pollution])
void main() {
  testWidgets('Weather tab presents weather info', (WidgetTester tester) async {
    // Define expected values
    var expectedCountry = 'Country';
    var expectedCity = 'City';
    num expectedC = 6;
    var expectedWeatherType = WeatherType.thunderstorm;
    var cSymbol = 'C';
    var aqiColor = Colors.amberAccent;
    int aqiUS = 20;
    var mainUS = 'O2';
    num humidity = 69;
    num pressure = 1000;
    num windSpeed = 88;
    var windDescription = 'windy';
    num windDegree = 90;
    IconData beaufort = Icons.android;

    // Create mocks
    var mockWeather = MockCityWeather();
    var mockForecast = MockWeather();
    var mockLocation = MockLocation();
    var mockTemp = MockTemperature();
    var mockPollution = MockPollution();

    when(mockLocation.lat).thenReturn(0);
    when(mockLocation.long).thenReturn(0);
    when(mockWeather.location).thenReturn(mockLocation);
    when(mockWeather.country).thenReturn(expectedCountry);
    when(mockWeather.city).thenReturn(expectedCity);
    when(mockWeather.weather).thenReturn(mockForecast);
    when(mockForecast.temperature).thenReturn(mockTemp);
    when(mockTemp.c).thenReturn(expectedC);
    when(mockTemp.cSymbol).thenReturn(cSymbol);
    when(mockForecast.type).thenReturn(expectedWeatherType);
    when(mockWeather.pollution).thenReturn(mockPollution);
    when(mockPollution.aqiColor).thenReturn(aqiColor);
    when(mockPollution.aqiUS).thenReturn(aqiUS);
    when(mockPollution.mainUS).thenReturn(mainUS);
    when(mockForecast.humidity).thenReturn(humidity);
    when(mockForecast.pressure).thenReturn(pressure);
    when(mockForecast.windSpeed).thenReturn(windSpeed);
    when(mockForecast.windDescription).thenReturn(windDescription);
    when(mockForecast.windDirection).thenReturn(windDegree);
    when(mockForecast.beaufortIcon).thenReturn(beaufort);

    await tester.pumpWidget(MaterialApp(
        home: WeatherTab(
      cityWeather: mockWeather,
      showMap: false,
    )));

    // Find city and country name
    expect(find.text('$expectedCity, $expectedCountry'), findsOneWidget);

    // Find temperature
    expect(find.text('$expectedC'), findsOneWidget);
    expect(find.text(cSymbol), findsOneWidget);

    // Find Wind
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('$windSpeed m/s'), findsOneWidget);
    expect(find.text(windDescription), findsOneWidget);

    // Find Air Quality
    expect(find.text('Air Quality'), findsOneWidget);
    expect(find.text(aqiUS.toString()), findsOneWidget);
    expect(find.byIcon(Icons.speed), findsOneWidget);
    expect(find.byIcon(Icons.masks), findsOneWidget);

    // Find humidity / pressure
    expect(find.text('Atmosphere'), findsOneWidget);
    expect(find.text('$humidity%'), findsOneWidget);
    expect(find.text('$pressure hPa'), findsOneWidget);
  });
}
