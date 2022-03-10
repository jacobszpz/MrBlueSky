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
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Image.asset('images/earth.jpg', fit: BoxFit.cover),
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle1?.fontSize),
            ),
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
