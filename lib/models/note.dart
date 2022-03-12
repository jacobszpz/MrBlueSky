import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mr_blue_sky/models/weather_type.dart';

class Note {
  String title = "";
  String content = "";
  WeatherType weather = WeatherType.clearSkyDay;
  DateTime timestamp = DateTime.now();

  Note(this.title, this.content, this.weather);
  Note.withTimestamp(this.title, this.content, this.weather, this.timestamp);
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

  @override
  String toString() {
    return 'Note: $title';
  }

  bool get isEmpty {
    return title.isEmpty && content.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  String get timestampMessage {
    String dateMsg = "";
    var now = DateTime.now();
    bool sameDay = (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year);
    if (sameDay) {
      dateMsg = DateFormat.jm().format(timestamp);
    } else {
      dateMsg = DateFormat.yMMMMd().format(timestamp);
    }
    return 'Last edited $dateMsg';
  }
}
