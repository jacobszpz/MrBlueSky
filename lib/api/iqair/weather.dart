import 'package:mr_blue_sky/api/temperature.dart';
import 'package:mr_blue_sky/api/weather_type.dart';

class Weather {
  DateTime timestamp = DateTime.now();
  Temperature temperature = Temperature.celsius(0);
  num pressure = 0;
  num humidity = 0;
  num windSpeed = 0;
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

  Weather(Map<String, dynamic> forecast) {
    timestamp = DateTime.parse(forecast['ts']);
    temperature = Temperature.celsius(forecast['tp']);
    pressure = forecast['pr'];
    humidity = forecast['hu'];
    windSpeed = forecast['ws'];
    windDirection = forecast['wd'];
    type = icons[forecast['ic']] ?? WeatherType.clearSkyDay;
  }

  Weather.empty();
}
