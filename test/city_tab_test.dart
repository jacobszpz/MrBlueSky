import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/models/fav_city.dart';
import 'package:mr_blue_sky/views/cities/city_tab.dart';

import 'city_tab_test.mocks.dart';

@GenerateMocks([City, FavCity])
void main() {
  testWidgets('City tab empty list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: CityTab(
      cities: [],
    )));

    expect(find.text('Your favourite cities will appear here'), findsOneWidget);
  });

  testWidgets('City tab single city', (WidgetTester tester) async {
    var mockFav = MockFavCity();
    var mockCity = MockCity();
    var city = 'City';
    var country = 'Country';

    when(mockCity.city).thenReturn(city);
    when(mockCity.country).thenReturn(country);
    when(mockFav.city).thenReturn(mockCity);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CityTab(
      cities: [mockFav],
    ))));

    expect(find.text('Your favourite cities will appear here'), findsNothing);
    expect(find.text('$city, $country'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('City tab onTap callback', (WidgetTester tester) async {
    var mockFav = MockFavCity();
    var mockCity = MockCity();
    var city = 'City';
    var country = 'Country';
    final completer = Completer<int>();

    when(mockCity.city).thenReturn(city);
    when(mockCity.country).thenReturn(country);
    when(mockFav.city).thenReturn(mockCity);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CityTab(
      cities: [mockFav],
      onTap: ((int index) {
        completer.complete(index);
      }),
    ))));

    await tester.tap(find.byType(ListTile));
    expect(completer.isCompleted, isTrue);
  });

  testWidgets('City tab onFavTap callback', (WidgetTester tester) async {
    var mockFav = MockFavCity();
    var mockCity = MockCity();
    var city = 'City';
    var country = 'Country';
    final completer = Completer<int>();

    when(mockCity.city).thenReturn(city);
    when(mockCity.country).thenReturn(country);
    when(mockFav.city).thenReturn(mockCity);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CityTab(
      cities: [mockFav],
      onFavTap: ((int index) {
        completer.complete(index);
      }),
    ))));

    await tester.tap(find.byType(IconButton));
    expect(completer.isCompleted, isTrue);
  });
}
