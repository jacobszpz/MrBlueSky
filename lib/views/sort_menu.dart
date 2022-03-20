import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';

/// PopupMenu with different sorting criteria
class SortMenu extends StatelessWidget {
  const SortMenu(
      {Key? key,
      required this.onSelected,
      required this.showDistanceSort,
      required this.enabled})
      : super(key: key);
  final Function(SortingOrder) onSelected;
  final bool showDistanceSort;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      enabled: enabled,
      icon:
          Icon(Icons.sort, color: Theme.of(context).colorScheme.inverseSurface),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<SortingOrder>>[
          const PopupMenuItem(
            child: Text('Alphabetically'),
            value: SortingOrder.alphabet,
          ),
          const PopupMenuItem(
            child: Text('Date Added'),
            value: SortingOrder.time,
          ),
          if (showDistanceSort)
            const PopupMenuItem(
              child: Text('Distance'),
              value: SortingOrder.distance,
            )
        ];
      },
      onSelected: (SortingOrder order) => onSelected(order),
    );
  }
}
