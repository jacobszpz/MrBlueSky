import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';

import 'city_container.dart';

class CityTab extends StatelessWidget {
  const CityTab(
      {Key? key,
      required this.cities,
      this.controller,
      this.onTap,
      this.onFavTap})
      : super(key: key);

  final List<City> cities;
  final ScrollController? controller;
  final Function(int index)? onTap;
  final Function(int index)? onFavTap;

  @override
  Widget build(BuildContext context) {
    return cities.isNotEmpty
        ? ListView.separated(
            controller: controller,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0, thickness: 1.5);
            },
            padding: const EdgeInsets.all(0),
            itemCount: cities.length,
            itemBuilder: (BuildContext context, int index) {
              return CityContainer(
                  city: cities.elementAt(index),
                  isFavourite: true,
                  onTap: (() {
                    onTap!(index);
                  }),
                  onFavTap: ((bool favourite) {
                    onFavTap!(index);
                  }));
            })
        : const Center(child: Text("Your favourite cities will appear here"));
  }
}
