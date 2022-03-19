import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class WeatherMap extends StatefulWidget {
  const WeatherMap(
      {Key? key, required this.centerCoords, this.zoom, this.onTap})
      : super(key: key);
  final Function(TapPosition, LatLng)? onTap;
  final LatLng centerCoords;
  final double? zoom;
  @override
  State<WeatherMap> createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap> {
  final _mapController = MapController();
  final String openstreet =
      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  final String openweather =
      "https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=7552dcd03e2863866c209f6f1981985f";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          enableScrollWheel: true,
          onTap: ((TapPosition pos, LatLng latlng) {
            widget.onTap!(pos, latlng);
          }),
          center: widget.centerCoords,
          zoom: widget.zoom ?? 1),
      layers: [
        TileLayerOptions(
          urlTemplate: openstreet,
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return Text("© OpenStreetMap",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1?.fontSize));
          },
        ),
        TileLayerOptions(
          opacity: 0.6,
          urlTemplate: openweather,
          attributionBuilder: (_) {
            return Text("© OpenWeatherMap",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle2?.fontSize));
          },
        )
      ],
    );
  }
}
