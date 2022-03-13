import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';

import 'city_container.dart';

class CityTab extends StatefulWidget {
  const CityTab({Key? key, required this.cities, this.controller, this.onTap})
      : super(key: key);

  final List<City> cities;
  final ScrollController? controller;
  final Function(int index)? onTap;

  @override
  State<CityTab> createState() => _CityTabState();
}

class _CityTabState extends State<CityTab> {
  List<City> cities = [];

  @override
  Widget build(BuildContext context) {
    cities = widget.cities;
    return cities.isNotEmpty
        ? ListView.separated(
            controller: widget.controller,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0, thickness: 1.5);
            },
            padding: const EdgeInsets.all(0),
            itemCount: cities.length,
            itemBuilder: (BuildContext context, int index) {
              City city = cities.elementAt(index);
              return CityContainer(
                  city: city,
                  onTap: (() {
                    widget.onTap!(index);
                  }));
            })
        : const Center(child: Text("..."));
  }
}
