import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/iqair/location.dart';
import 'package:mr_blue_sky/views/weather_map.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({Key? key, required this.cityWeather, this.onTapWeather})
      : super(key: key);
  final Function()? onTapWeather;
  final CityWeather cityWeather;

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  LatLng _locationToLatLng(Location location) {
    return LatLng(location.lat, location.long);
  }

  Widget _weatherMap(
      {required Function(TapPosition pos, LatLng latlng)? onTap}) {
    return WeatherMap(
        centerCoords: _locationToLatLng(widget.cityWeather.location),
        zoom: 11,
        onTap: ((TapPosition pos, LatLng latlng) {
          onTap!(pos, latlng);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: <Widget>[
          Card(
            child: InkWell(
              onTap: (() {}),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        "${widget.cityWeather.city}, ${widget.cityWeather.country}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.fontSize)),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                              child: Icon(
                            Icons.sunny,
                            size: 120,
                          )),
                          const Spacer(),
                          Text("${widget.cityWeather.weather.temperature}°",
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.fontSize)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 16),
          Container(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxHeight: 300, minHeight: 40),
              child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                      onTap: (() {}),
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Hero(
                                  tag: "hero-weather-map",
                                  child: _weatherMap(
                                      onTap: ((TapPosition pos, LatLng latlng) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Hero(
                                              tag: "hero-weather-map",
                                              child: _weatherMap(
                                                  onTap: ((TapPosition pos,
                                                      LatLng latlng) {})))),
                                    );
                                  })))))))),
          /*GridView(gridDelegate:
          children<Widget>: [

          ]),*/
        ],
      ),
    );
  }
}
