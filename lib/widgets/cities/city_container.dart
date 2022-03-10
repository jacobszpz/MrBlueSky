import 'package:flutter/material.dart';

class CityContainer extends StatefulWidget {
  const CityContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CityContainer> createState() => _CityContainerState();
}

class _CityContainerState extends State<CityContainer> {
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 80,
      child: Row(
        children: <Widget>[
          Text(widget.title),
          const Spacer(),
          IconButton(
              icon: Icon(_favourite ? Icons.favorite : Icons.favorite_outline),
              onPressed: () {
                setState(() {
                  _favourite = !_favourite;
                });
              }
          ),
        ],
      ),
    );
  }
}