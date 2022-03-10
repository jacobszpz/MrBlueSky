class Pollution {
  DateTime timestamp =  DateTime.now();
  int aqiUS = 0;
  int aqiCN = 0;

  Pollution.empty();
  Pollution(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    aqiUS = forecast['aqius'];
    aqiCN = forecast['aqicn'];
  }
}