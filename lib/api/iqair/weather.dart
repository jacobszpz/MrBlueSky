class Weather {
  DateTime timestamp =  DateTime.now();
  int temperature = 0;
  int pressure = 0;
  int humidity = 0;
  double windSpeed = 0;
  int windDirection = 0;
  String iconCode = "";

  Weather(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    temperature = forecast['tp'];
    pressure = forecast['pr'];
    humidity = forecast['hu'];
    windSpeed = forecast['ws'];
    windDirection = forecast['wd'];
    iconCode = forecast['ic'];
  }

  Weather.empty();
}