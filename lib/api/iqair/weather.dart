import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/temperature.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:weather_icons/weather_icons.dart';

class Weather {
  DateTime timestamp = DateTime.now();
  Temperature temperature = Temperature.celsius(0);
  num pressure = 0;
  num humidity = 0;
  num windSpeed = 0;
  int windCategory = 0;
  num windDirection = 0;
  WeatherType type = WeatherType.clearSkyDay;

  final Map<String, WeatherType> icons = {
    "01d": WeatherType.clearSkyDay, // clear sky, day
    "01n": WeatherType.clearSkyNight, // clear sky, night
    "02d": WeatherType.fewCloudsDay, // few clouds, day
    "02n": WeatherType.fewCloudsNight, // few clouds, night
    "03d": WeatherType.scatteredClouds, // scattered clouds
    "04d": WeatherType.brokenClouds, // broken clouds
    "09d": WeatherType.showerRain, // shower rain
    "10d": WeatherType.rainDay, // rain, day
    "10n": WeatherType.rainNight, // rain, night
    "11d": WeatherType.thunderstorm, // thunderstorm
    "13n": WeatherType.snow, // snow
    "50n": WeatherType.mist, // mist
  };

  List<IconData> beaufortIcons = [
    WeatherIcons.wind_beaufort_0,
    WeatherIcons.wind_beaufort_1,
    WeatherIcons.wind_beaufort_2,
    WeatherIcons.wind_beaufort_3,
    WeatherIcons.wind_beaufort_4,
    WeatherIcons.wind_beaufort_5,
    WeatherIcons.wind_beaufort_6,
    WeatherIcons.wind_beaufort_7,
    WeatherIcons.wind_beaufort_8,
    WeatherIcons.wind_beaufort_9,
    WeatherIcons.wind_beaufort_10,
    WeatherIcons.wind_beaufort_11,
    WeatherIcons.wind_beaufort_12,
  ];

  final List<num> windCategories = [
    0,
    0.5,
    1.6,
    3.4,
    5.5,
    8,
    10.8,
    13.9,
    17.2,
    20.8,
    24.5,
    28.5,
    32.7,
  ];

  final List<String> windSpeedDescriptions = [
    'Calm',
    'Light air',
    'Light breeze',
    'Gentle breeze',
    'Moderate breeze',
    'Fresh breeze',
    'Strong breeze',
    'High wind',
    'Strong wind',
    'Severe wind',
    'Storm',
    'Violent storm',
    'Hurricane'
  ];

  static const num maxWindSpeed = 32.7;

  String get windDescription {
    return windSpeedDescriptions[windCategory];
  }

  int get beaufortScale {
    return windCategory;
  }

  IconData get beaufortIcon {
    return beaufortIcons[windCategory];
  }

  Weather(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    temperature = Temperature.celsius(forecast['tp']);
    pressure = forecast['pr'];
    humidity = forecast['hu'];
    windSpeed = forecast['ws'];
    windDirection = forecast['wd'];
    type = icons[forecast['ic']] ?? WeatherType.clearSkyDay;
    if (windSpeed < 0) {
      windSpeed = 0;
    }
    int currentKey = -1;
    for (var windCategory in windCategories) {
      if (windCategory > windSpeed) {
        break;
      }
      currentKey++;
    }
    windCategory = currentKey;
  }

  Weather.empty();
}
