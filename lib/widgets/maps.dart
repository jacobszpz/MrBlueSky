import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key, this.onTap}) : super(key: key);
  final Function(TapPosition, LatLng)? onTap;
  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final _mapController = MapController();

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
        center: LatLng(51.5, -0.09),
        zoom: 3.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return Text("© OpenStreetMap",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1?.fontSize));
          },
        ),
        TileLayerOptions(
          opacity: 0.8,
          urlTemplate:
              "https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=7552dcd03e2863866c209f6f1981985f",
          subdomains: ['a', 'b', 'c'],
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
