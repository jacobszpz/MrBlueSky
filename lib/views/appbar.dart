import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';
import 'package:mr_blue_sky/views/sort_menu.dart';

/// AppBar widget that features a TabBar and Search Icon
class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  const MyAppBar(
      {Key? key,
      required this.title,
      required this.tabController,
      this.onSearch,
      this.onTabBarTap,
      this.onSort})
      : super(key: key);

  final String title;
  final Function()? onSearch;
  final Function(int index)? onTabBarTap;
  final Function(SortingOrder order)? onSort;
  final TabController tabController;

  static const List<Tab> tabs = <Tab>[
    Tab(text: "WEATHER"),
    Tab(text: "MY CITIES"),
    Tab(text: "MY NOTES"),
  ];

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(title),
        bottom: TabBar(
          indicatorColor: Theme.of(context).colorScheme.secondary,
          onTap: ((index) {
            final _onTabBarTap = onTabBarTap;
            if (_onTabBarTap != null) {
              _onTabBarTap(index);
            }
          }),
          controller: tabController,
          tabs: MyAppBar.tabs,
        ),
        actions: <Widget>[
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (tabController.index != 0) ? 1 : 0,
            child: SortMenu(
                enabled: (tabController.index != 0),
                showDistanceSort: tabController.index == 1,
                onSelected: ((SortingOrder order) {
                  final _onSort = onSort;
                  if (_onSort != null) {
                    _onSort(order);
                  }
                })),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            color: Theme.of(context).colorScheme.inverseSurface,
            tooltip: 'Search city',
            onPressed: () {
              final _onSearch = onSearch;
              if (_onSearch != null) {
                _onSearch();
              }
            },
          )
        ]);
  }
}
