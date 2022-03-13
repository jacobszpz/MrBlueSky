import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/views/settings.dart';

class MyAppDrawer extends StatefulWidget {
  MyAppDrawer({Key? key, this.loggedUser, this.onSignIn, this.onSignOut})
      : super(key: key);
  User? loggedUser;
  Function(BuildContext)? onSignOut;
  Function(BuildContext, SignedIn)? onSignIn;

  @override
  State<MyAppDrawer> createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  BoxDecoration _drawerDecoration() {
    return const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
            image: AssetImage('images/earth.jpg'), fit: BoxFit.cover));
  }

  TextStyle _drawerTileTextStyle() {
    return TextStyle(fontSize: Theme.of(context).textTheme.subtitle1?.fontSize);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((User? user) {});
  }

  @override
  Widget build(BuildContext context) {
    User? loggedUser = widget.loggedUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          loggedUser != null
              ? UserAccountsDrawerHeader(
                  accountEmail: Text(loggedUser.email ?? ""),
                  accountName: Text(loggedUser.displayName ?? ""),
                  currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.black45,
                      backgroundImage: NetworkImage(loggedUser.photoURL ?? "")),
                  decoration: _drawerDecoration(),
                )
              : DrawerHeader(
                  decoration: _drawerDecoration(),
                  child: const SizedBox.shrink()),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle1?.fontSize),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(createSettingsRoute());
            },
          ),
          loggedUser != null
              ? ListTile(
                  title: Text('Account', style: _drawerTileTextStyle()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(actions: [
                                  SignedOutAction((context) {
                                    widget.onSignOut!(context);
                                  }),
                                ])));
                  },
                )
              : ListTile(
                  title: Text(
                    'Log In',
                    style: _drawerTileTextStyle(),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen(
                                    actions: [
                                      AuthStateChangeAction<SignedIn>(
                                          (context, state) {
                                        widget.onSignIn!(context, state);
                                      }),
                                    ],
                                  )));
                    });
                  },
                )
        ],
      ),
    );
  }
}
