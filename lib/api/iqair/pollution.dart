class Pollution {
  DateTime timestamp = DateTime.now();
  int aqiUS = 0;
  int aqiCN = 0;
  String mainUS = '';
  String mainCN = '';

  final Map<String, String> pollutants = {
    "p2": "PM2.5", //pm2.5
    "p1": "PM10", //pm10
    "o3": "O3", //Ozone O3
    "n2": "NO2", //Nitrogen dioxide NO2
    "s2": "SO2", //Sulfur dioxide SO2
    "co": "CO" //Carbon monoxide CO
  };

  Pollution.empty();
  Pollution(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    aqiUS = forecast['aqius'];
    aqiCN = forecast['aqicn'];
    mainUS = pollutants[forecast['mainus']] ?? '?';
    mainCN = pollutants[forecast['maincn']] ?? '?';
  }
}
