import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:test/test.dart';
import 'package:weather_icons/weather_icons.dart';

import 'fav_city_test.mocks.dart';

void main() {
  group('Note', () {
    test('title getter', () {
      var expectedTitle = 'title';
      var a = Note.fromNew(expectedTitle, '', WeatherType.clearSkyDay);
      expect(a.title, expectedTitle);
    });

    test('content getter', () {
      var expectedContent = 'content';
      var a = Note.fromNew('', expectedContent, WeatherType.clearSkyDay);
      expect(a.content, expectedContent);
    });

    test('weather type getter', () {
      var expectedType = WeatherType.thunderstorm;
      var a = Note.fromWeather(expectedType);
      expect(a.weather, expectedType);
    });

    test('weather uuid getter', () {
      var expectedUUID = 'this is the uuid';
      var a = Note.fromExisting('', '', WeatherType.clearSkyDay, MockDateTime(),
          MockDateTime(), expectedUUID);
      expect(a.uuid, expectedUUID);
    });

    test('toString', () {
      var expectedTitle = 'title';
      var a = Note.fromNew(expectedTitle, '', WeatherType.clearSkyDay);
      expect(a.toString(), 'Note: $expectedTitle');
    });

    test('empty note is empty', () {
      var a = Note.empty();
      expect(a.isEmpty, true);
    });

    test('created empty note is empty', () {
      var a = Note.fromNew('', '', WeatherType.clearSkyDay);
      expect(a.isEmpty, true);
    });

    test('note with title is not empty', () {
      var a = Note.fromNew('title', '', WeatherType.clearSkyDay);
      expect(a.isEmpty, false);
    });

    test('note with content is not empty', () {
      var a = Note.fromNew('', 'content', WeatherType.clearSkyDay);
      expect(a.isEmpty, false);
    });

    test('icons', () {
      var a = Note.fromWeather(WeatherType.clearSkyDay);
      expect(a.icon, WeatherIcons.day_sunny);

      var b = Note.fromWeather(WeatherType.clearSkyNight);
      expect(b.icon, WeatherIcons.night_clear);

      var c = Note.fromWeather(WeatherType.rainDay);
      expect(c.icon, WeatherIcons.day_rain);

      var d = Note.fromWeather(WeatherType.snow);
      expect(d.icon, WeatherIcons.snow);
    });
  });
}
