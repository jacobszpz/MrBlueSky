import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mr_blue_sky/widgets/maps.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({Key? key, this.onTapWeather}) : super(key: key);
  final Function()? onTapWeather;
  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  Widget _weatherMap(
      {required Function(TapPosition pos, LatLng latlng)? onTap}) {
    return MyMap(onTap: ((TapPosition pos, LatLng latlng) {
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
                    Text('Preston, United Kingdom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.fontSize)),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.sunny,
                            size: 120,
                          ),
                          Spacer(),
                          Text("15°",
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.fontSize)),
                          Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(maxHeight: 300, minHeight: 40),
              child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                      onTap: (() {
                        log('fuck');
                      }),
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
                                  }))))))))
        ],
      ),
    );
  }
}
