import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';

class WeatherWrapper extends StatefulWidget {
  WeatherWrapper(
      {Key? key,
      required this.weather,
      required this.favourite,
      required this.onShare,
      required this.onFavTap});
  final bool favourite;
  final CityWeather weather;
  Function() onShare;
  Function(bool favourite) onFavTap;

  @override
  State<StatefulWidget> createState() => _WeatherWrapperState();
}

class _WeatherWrapperState extends State<WeatherWrapper> {
  bool favourite = false;
  CityWeather cityWeather = CityWeather.empty();

  @override
  void initState() {
    favourite = widget.favourite;
    cityWeather = widget.weather;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Weather at ${cityWeather.city}'),
          actions: <Widget>[
            IconButton(
                onPressed: (() {
                  setState(() {
                    favourite = !favourite;
                  });
                  widget.onFavTap(favourite);
                }),
                icon:
                    Icon(favourite ? Icons.favorite : Icons.favorite_outline)),
            IconButton(
                onPressed: (() {
                  widget.onShare();
                }),
                icon: const Icon(Icons.share))
          ],
        ),
        body: WeatherTab(cityWeather: cityWeather));
  }
}
