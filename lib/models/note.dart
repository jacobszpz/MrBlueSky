import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/weather_type.dart';

class Note {
  String title = "";
  String content = "";
  WeatherType weather = WeatherType.clearSkyDay;

  Note(this.title, this.content, this.weather);
  Note.empty();

  IconData get icon {
    switch (weather) {
      case WeatherType.clearSkyDay:
        return Icons.sunny;
      case WeatherType.clearSkyNight:
        return Icons.nightlight_round;
      case WeatherType.brokenClouds:
        return Icons.cloud;
      default:
        return Icons.sunny;
    }
  }
}
