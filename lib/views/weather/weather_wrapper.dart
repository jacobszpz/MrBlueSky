import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/views/weather/weather_tab.dart';
import 'package:share_plus/share_plus.dart';

class WeatherWrapper extends StatefulWidget {
  const WeatherWrapper(
      {Key? key,
      required this.cityWeather,
      required this.favourite,
      required this.onFavTap})
      : super(key: key);
  final bool favourite;
  final CityWeather cityWeather;
  final Function(bool favourite) onFavTap;

  @override
  State<StatefulWidget> createState() => _WeatherWrapperState();
}

class _WeatherWrapperState extends State<WeatherWrapper> {
  bool favourite = false;

  @override
  void initState() {
    favourite = widget.favourite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Weather at ${widget.cityWeather.city}'),
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
                  Share.share(widget.cityWeather.getShareMsg);
                }),
                icon: const Icon(Icons.share))
          ],
        ),
        body: WeatherTab(cityWeather: widget.cityWeather));
  }
}
