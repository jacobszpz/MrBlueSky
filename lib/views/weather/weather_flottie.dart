import 'package:mr_blue_sky/api/weather_type.dart';

class WeatherFlottieAssets {
  static String fromWeatherType(WeatherType type) {
    String prefix = 'images/icons/lottie/';
    String asset;

    switch (type) {
      case WeatherType.clearSkyDay:
        asset = 'clear-day.json';
        break;
      case WeatherType.clearSkyNight:
        asset = 'clear-night.json';
        break;
      case WeatherType.fewCloudsDay:
        asset = 'partly-cloudy-day.json';
        break;
      case WeatherType.fewCloudsNight:
        asset = 'partly-cloudy-night.json';
        break;
      case WeatherType.scatteredClouds:
        asset = 'cloudy.json';
        break;
      case WeatherType.brokenClouds:
        asset = 'overcast.json';
        break;
      case WeatherType.showerRain:
        asset = 'drizzle.json';
        break;
      case WeatherType.rainDay:
        asset = 'partly-cloudy-day-rain.json';
        break;
      case WeatherType.rainNight:
        asset = 'partly-cloudy-night-rain.json';
        break;
      case WeatherType.thunderstorm:
        asset = 'thunderstorms.json';
        break;
      case WeatherType.snow:
        asset = 'snow.json';
        break;
      case WeatherType.mist:
        asset = 'mist.json';
        break;
    }

    return prefix + asset;
  }
}
