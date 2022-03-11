import 'package:flutter/material.dart';

import 'city_container.dart';

class CityTab extends StatefulWidget {
  const CityTab({Key? key}) : super(key: key);

  @override
  State<CityTab> createState() => _CityTabState();
}

class _CityTabState extends State<CityTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: const <Widget>[
        CityContainer(title: "Preston, England"),
        CityContainer(title: "Manchester, England"),
        CityContainer(title: "London, England")
      ],
    );
  }
}
