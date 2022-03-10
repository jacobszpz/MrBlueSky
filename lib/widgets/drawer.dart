import 'package:flutter/material.dart';


class MyAppDrawer extends StatefulWidget {
  const MyAppDrawer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyAppDrawer> createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Mr Blue Sky'),
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
