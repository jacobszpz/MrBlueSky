import 'package:flutter/material.dart';
import 'package:mr_blue_sky/api/city.dart';

class CityContainer extends StatefulWidget {
  const CityContainer(
      {Key? key,
      required this.city,
      required this.isFavourite,
      this.onTap,
      this.onFavTap})
      : super(key: key);
  final City city;
  final bool isFavourite;
  final Function()? onTap;
  final Function(bool favourite)? onFavTap;

  @override
  State<CityContainer> createState() => _CityContainerState();
}

class _CityContainerState extends State<CityContainer> {
  @override
  Widget build(BuildContext context) {
    var favourite = widget.isFavourite;
    return Container(
      padding: const EdgeInsets.all(8),
      height: 80,
      child: ListTile(
        onTap: () {
          widget.onTap!();
        },
        title: Text('${widget.city.city}, ${widget.city.country}'),
        trailing: IconButton(
            icon: Icon(favourite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () {
              setState(() {
                widget.onFavTap!(!favourite);
              });
            }),
      ),
    );
  }
}
