import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mr_blue_sky/api/city.dart';
import 'package:mr_blue_sky/models/coords.dart';
import 'package:mr_blue_sky/models/fav_city.dart';
import 'package:test/test.dart';

import 'fav_city_test.mocks.dart';

@GenerateMocks([City, Coordinates, DateTime])
void main() {
  group('Favourite City', () {
    test('dateAdded getter', () {
      var mockDateTime = MockDateTime();
      var a = FavCity(MockCity(), MockCoordinates(), mockDateTime);
      expect(a.dateAdded, mockDateTime);
    });

    test('location getter', () {
      var mockCoords = MockCoordinates();
      var a = FavCity.justAdded(MockCity(), mockCoords);
      expect(a.location, mockCoords);
    });

    test('city getter', () {
      var mockCity = MockCity();
      var a = FavCity.justAdded(mockCity, MockCoordinates());
      expect(a.city, mockCity);
    });

    test('toMap', () {
      double expectedLat = 40;
      double expectedLong = 50;
      int expectedMilliseconds = 60;

      var mockCoords = MockCoordinates();
      when(mockCoords.lat).thenReturn(expectedLat);
      when(mockCoords.long).thenReturn(expectedLong);

      var mockDate = MockDateTime();
      when(mockDate.millisecondsSinceEpoch).thenReturn(expectedMilliseconds);

      var a = FavCity(MockCity(), mockCoords, mockDate);
      var favCityMap = a.toMap();
      expect(favCityMap[FavCityFields.lat], expectedLat);
      expect(favCityMap[FavCityFields.long], expectedLong);
      expect(favCityMap[FavCityFields.dateAdded], expectedMilliseconds);
    });

    test('toDBMap', () {
      double expectedLat = 40;
      double expectedLong = 50;
      int expectedMilliseconds = 60;
      String expectedBase64 = 'citybase64';
      var mockCoords = MockCoordinates();
      when(mockCoords.lat).thenReturn(expectedLat);
      when(mockCoords.long).thenReturn(expectedLong);

      var mockDate = MockDateTime();
      when(mockDate.millisecondsSinceEpoch).thenReturn(expectedMilliseconds);

      var mockCity = MockCity();
      when(mockCity.toBase64).thenReturn(expectedBase64);

      var a = FavCity(mockCity, mockCoords, mockDate);
      var favCityMap = a.toDBMap();
      expect(favCityMap[FavCityFields.lat], expectedLat);
      expect(favCityMap[FavCityFields.long], expectedLong);
      expect(favCityMap[FavCityFields.dateAdded], expectedMilliseconds);
      expect(favCityMap[FavCityFields.hash], expectedBase64);
    });
  });
}
