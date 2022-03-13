import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/iqair/city.dart';

class CityContainer extends StatefulWidget {
  const CityContainer({Key? key, required this.city, this.onTap})
      : super(key: key);
  final City city;
  final Function()? onTap;

  @override
  State<CityContainer> createState() => _CityContainerState();
}

class _CityContainerState extends State<CityContainer> {
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 80,
      child: ListTile(
        onTap: () {
          widget.onTap!();
        },
        title: Text('${widget.city.city}, ${widget.city.country}'),
        trailing: IconButton(
            icon: Icon(_favourite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () {
              setState(() {
                _favourite = !_favourite;
              });
            }),
      ),
    );
  }
}
