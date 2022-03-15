import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:mr_blue_sky/api/iqair/city_weather.dart';
import 'package:mr_blue_sky/api/iqair/location.dart';
import 'package:mr_blue_sky/views/weather/weather_flottie.dart';
import 'package:mr_blue_sky/views/weather_map.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab(
      {Key? key,
      required this.cityWeather,
      this.onTapWeather,
      this.scrollController})
      : super(key: key);
  final Function()? onTapWeather;
  final CityWeather? cityWeather;
  final ScrollController? scrollController;

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

enum WeatherWidgets {
  weatherMap,
  windCard,
  airQualityCard,
  pressureAndHumidity
}

class _WeatherTabState extends State<WeatherTab> {
  Color iconColour = Colors.blue;
  final double iconSize = 40;

  List<WeatherWidgets> widgetOrder = [
    WeatherWidgets.weatherMap,
    WeatherWidgets.windCard,
    WeatherWidgets.airQualityCard,
    WeatherWidgets.pressureAndHumidity
  ];

  LatLng _locationToLatLng(Location location) {
    return LatLng(location.lat, location.long);
  }

  Widget _weatherMap(
      {required Function(TapPosition pos, LatLng latlng)? onTap}) {
    Location weatherLocation = widget.cityWeather?.location ?? Location.empty();
    return WeatherMap(
        centerCoords: _locationToLatLng(weatherLocation),
        zoom: 11,
        onTap: ((TapPosition pos, LatLng latlng) {
          onTap!(pos, latlng);
        }));
  }

  Widget _mainCard() {
    CityWeather cityWeather = widget.cityWeather ?? CityWeather.empty();
    return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("${cityWeather.city}, ${cityWeather.country}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize)),
            Container(
              //padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Lottie.asset(WeatherFlottieAssets.fromWeatherType(
                        cityWeather.weather.type)),
                  ),
                  Row(children: [
                    Text("${cityWeather.weather.temperature}°",
                        style: const TextStyle(fontSize: 70)),
                  ]),
                ],
              ),
            ),
          ],
        ));
  }

  Text _weatherCardTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style:
          TextStyle(fontSize: Theme.of(context).textTheme.subtitle1?.fontSize),
    );
  }

  Card _weatherCardWrapper(Widget child,
      {Key? key, Widget? title, BoxConstraints? constraints}) {
    return Card(
        key: key,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: (() {}),
            child: Container(
                padding: const EdgeInsets.all(20),
                constraints: constraints,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [if (title != null) title, child]))));
  }

  Widget _mapContainer({Key? key}) {
    Widget child = Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Hero(
              tag: "hero-weather-map",
              child: _weatherMap(onTap: ((TapPosition pos, LatLng latlng) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Hero(
                          tag: "hero-weather-map",
                          child: _weatherMap(
                              onTap: ((TapPosition pos, LatLng latlng) {})))),
                );
              })))),
    ));

    return _weatherCardWrapper(child,
        key: key,
        title: _weatherCardTitle("Weather Map"),
        constraints: const BoxConstraints(maxHeight: 300, minHeight: 40));
  }

  Card _airQualityCard({Key? key}) {
    CityWeather cityWeather = widget.cityWeather ?? CityWeather.empty();
    double? fontSize = Theme.of(context).textTheme.headline6?.fontSize;
    double? smallFontSize = Theme.of(context).textTheme.subtitle1?.fontSize;

    Widget child = Row(
      children: [
        Expanded(
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.speed,
                size: iconSize,
                color: iconColour,
              ),
            ),
            title: Text(
              cityWeather.pollution.aqiUS.toString(),
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.masks,
                size: iconSize,
                color: iconColour,
              ),
            ),
            title: Text(
              cityWeather.pollution.mainUS,
              style: TextStyle(fontSize: smallFontSize),
            ),
          ),
        )
      ],
    );
    return _weatherCardWrapper(child,
        title: _weatherCardTitle("Air Quality"), key: key);
  }

  Card _pressureHumidityCard({Key? key}) {
    CityWeather cityWeather = widget.cityWeather ?? CityWeather.empty();
    double? fontSize = Theme.of(context).textTheme.headline6?.fontSize;
    var cardTextStyle = TextStyle(fontSize: fontSize);
    Widget child = Row(
      children: [
        Expanded(
            child: ListTile(
          leading: BoxedIcon(WeatherIcons.humidity,
              size: iconSize, color: iconColour),
          title: Text(
            '${cityWeather.weather.humidity}%',
            style: cardTextStyle,
          ),
        )),
        Expanded(
            child: ListTile(
          leading: BoxedIcon(WeatherIcons.barometer,
              size: iconSize, color: iconColour),
          title: Text(
            '${cityWeather.weather.pressure} hPa',
            style: cardTextStyle,
          ),
        ))
      ],
    );
    return _weatherCardWrapper(child,
        key: key, title: _weatherCardTitle("Atmosphere"));
  }

  Card _windCard({Key? key}) {
    CityWeather cityWeather = widget.cityWeather ?? CityWeather.empty();
    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('${cityWeather.weather.windSpeed} m/s',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline5?.fontSize)),
        WindIcon(
            size: 60,
            degree: cityWeather.weather.windDirection,
            color: iconColour),
      ],
    );
    return _weatherCardWrapper(child,
        title: _weatherCardTitle("Wind"), key: key);
  }

  Widget _getWidgetAtPosition(int index) {
    Widget listWidget = const SizedBox.shrink();
    Key key = Key(index.toString());
    if (widgetOrder.elementAt(index) == WeatherWidgets.weatherMap) {
      listWidget = _mapContainer(key: key);
    }
    if (widgetOrder.elementAt(index) == WeatherWidgets.windCard) {
      listWidget = _windCard(key: key);
    }
    if (widgetOrder.elementAt(index) == WeatherWidgets.airQualityCard) {
      listWidget = _airQualityCard(key: key);
    }
    if (widgetOrder.elementAt(index) == WeatherWidgets.pressureAndHumidity) {
      listWidget = _pressureHumidityCard(key: key);
    }

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    iconColour = Theme.of(context).colorScheme.secondary;

    return widget.cityWeather == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _mainCard(),
                Expanded(
                  child: ReorderableListView(
                    scrollController: widget.scrollController,
                    onReorder: ((int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final WeatherWidgets item =
                            widgetOrder.removeAt(oldIndex);
                        widgetOrder.insert(newIndex, item);
                      });
                    }),
                    children: <Widget>[
                      for (int i = 0; i < widgetOrder.length; ++i)
                        _getWidgetAtPosition(i)
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
