import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';

import 'city_container.dart';

class CityTab extends StatefulWidget {
  const CityTab(
      {Key? key,
      required this.cities,
      required this.favCities,
      this.controller,
      this.onTap,
      this.onFavTap})
      : super(key: key);

  final List<City> cities;
  final Map<String, bool> favCities;
  final ScrollController? controller;
  final Function(int index)? onTap;
  final Function(int index, bool favourite)? onFavTap;

  @override
  State<CityTab> createState() => _CityTabState();
}

class _CityTabState extends State<CityTab> {
  List<City> cities = [];
  Map<String, bool> favCities = {};
  @override
  Widget build(BuildContext context) {
    cities = widget.cities;
    favCities = widget.favCities;
    List<String> favCitiesList = List<String>.of(favCities.keys);

    return cities.isNotEmpty
        ? ListView.separated(
            controller: widget.controller,
            separatorBuilder: (BuildContext context, int index) {
              bool visible = true;
              if (index >= widget.favCities.length) {
                City city = cities.elementAt(index - favCitiesList.length);

                if (favCities.containsKey(city.toBase64)) {
                  visible = false;
                }
              }
              return Visibility(
                  child: const Divider(height: 0, thickness: 1.5),
                  visible: visible);
            },
            padding: const EdgeInsets.all(0),
            itemCount: cities.length + favCities.length,
            itemBuilder: (BuildContext context, int index) {
              bool isFavourite = false;
              bool visible = true;
              City city;

              if (index < widget.favCities.length) {
                city = City.fromBase64(favCitiesList[index]);
                isFavourite = true;
              } else {
                city = cities.elementAt(index - favCitiesList.length);

                if (favCities.containsKey(city.toBase64)) {
                  visible = false;
                }
              }

              return Visibility(
                visible: visible,
                child: CityContainer(
                    city: city,
                    isFavourite: isFavourite,
                    onTap: (() {
                      //widget.onTap!(index - favCities.length);
                    }),
                    onFavTap: ((bool favourite) {
                      //widget.onFavTap!(index - favCities.length, favourite);
                    })),
              );
            })
        : const Center(child: Text("..."));
  }
}
