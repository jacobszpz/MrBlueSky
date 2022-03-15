import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mr_blue_sky/api/weather_type.dart';
import 'package:uuid/uuid.dart';

class Note {
  String title = "";
  String content = "";
  WeatherType weather = WeatherType.clearSkyDay;
  DateTime editTimestamp = DateTime.now();
  DateTime creationTimestamp = DateTime.now();
  String uuid = const Uuid().v1();

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
