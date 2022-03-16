import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:uuid/uuid.dart';
import 'package:weather_icons/weather_icons.dart';

class Note {
  String title = "";
  String content = "";
  WeatherType weather = WeatherType.clearSkyDay;
  DateTime editTimestamp = DateTime.now();
  DateTime creationTimestamp = DateTime.now();
  String uuid = const Uuid().v1();

  Note.fromWeather(this.weather);
  Note.fromNew(this.title, this.content, this.weather);
  Note.fromExisting(this.title, this.content, this.weather, this.editTimestamp,
      this.creationTimestamp, this.uuid);
  Note.empty();

  Note.fromRTDB(String dbUUID, Map<String, dynamic> map) {
    title = map['title'];
    content = map['content'];
    editTimestamp = DateTime.fromMillisecondsSinceEpoch(map['editTimestamp']);
    creationTimestamp =
        DateTime.fromMillisecondsSinceEpoch(map['creationTimestamp']);
    weather = WeatherType.values.byName(map['weatherType']);
    uuid = dbUUID;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'content': content,
      'editTimestamp': editTimestamp.millisecondsSinceEpoch,
      'creationTimestamp': creationTimestamp.millisecondsSinceEpoch,
      'weatherType': weather.name
    };
  }

  IconData get icon {
    switch (weather) {
      case WeatherType.clearSkyDay:
        return WeatherIcons.day_sunny;
      case WeatherType.clearSkyNight:
        return WeatherIcons.night_clear;
      case WeatherType.brokenClouds:
        return WeatherIcons.cloudy;
      case WeatherType.fewCloudsDay:
        return WeatherIcons.day_cloudy;
      case WeatherType.fewCloudsNight:
        return WeatherIcons.night_alt_cloudy;
      case WeatherType.scatteredClouds:
        return WeatherIcons.cloud;

      case WeatherType.showerRain:
        return WeatherIcons.showers;

      case WeatherType.rainDay:
        return WeatherIcons.day_rain;

      case WeatherType.rainNight:
        return WeatherIcons.night_alt_rain;

      case WeatherType.thunderstorm:
        return WeatherIcons.thunderstorm;

      case WeatherType.snow:
        return WeatherIcons.snow;

      case WeatherType.mist:
        return WeatherIcons.fog;
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
    bool sameDay = (editTimestamp.day == now.day &&
        editTimestamp.month == now.month &&
        editTimestamp.year == now.year);
    if (sameDay) {
      dateMsg = DateFormat.jm().format(editTimestamp);
    } else {
      dateMsg = DateFormat.yMMMMd().format(editTimestamp);
    }
    return 'Last edited $dateMsg';
  }
}
