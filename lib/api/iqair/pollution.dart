import 'package:flutter/material.dart';

class Pollution {
  DateTime timestamp = DateTime.now();
  int aqiUS = 0;
  int aqiCN = 0;
  String mainUS = '';
  String mainCN = '';
  int aqiLevel = 0;

  static const String aqiURL = 'https://www.airnow.gov/aqi/aqi-basics/';

  final Map<String, String> pollutants = {
    "p2": "PM2.5", //pm2.5
    "p1": "PM10", //pm10
    "o3": "O3", //Ozone O3
    "n2": "NO2", //Nitrogen dioxide NO2
    "s2": "SO2", //Sulfur dioxide SO2
    "co": "CO" //Carbon monoxide CO
  };

  final List<int> aqiLevels = [0, 51, 101, 151, 201, 300];

  List<Color> aqiColors = [
    Colors.green.shade600,
    Colors.yellow.shade500,
    Colors.orange.shade500,
    Colors.red.shade500,
    Colors.purple.shade700,
    Colors.red.shade900
  ];

  Color get aqiColor {
    return aqiColors[aqiLevel];
  }

  Pollution.empty();
  Pollution(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    aqiUS = forecast['aqius'];
    aqiCN = forecast['aqicn'];
    mainUS = pollutants[forecast['mainus']] ?? '?';
    mainCN = pollutants[forecast['maincn']] ?? '?';

    int _aqiLevel = aqiLevels.length - 1;

    for (int i = 0; i < aqiLevels.length; i++) {
      if (aqiLevels.elementAt(i) > aqiUS) {
        _aqiLevel = i - 1;
        break;
      }
    }
    aqiLevel = _aqiLevel;
  }
}
