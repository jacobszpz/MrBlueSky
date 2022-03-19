import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/views/settings.dart';

class MyAppDrawer extends StatefulWidget {
  const MyAppDrawer({Key? key, this.onSignIn, this.onSignOut})
      : super(key: key);
  final Function(BuildContext)? onSignOut;
  final Function(BuildContext, SignedIn)? onSignIn;

  @override
  State<MyAppDrawer> createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  User? firebaseUser;

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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((userStream) {
      setState(() {
        firebaseUser = userStream;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          user != null
              ? UserAccountsDrawerHeader(
                  accountEmail: Text(user.email ?? ""),
                  accountName: Text(user.displayName ?? ""),
                  currentAccountPicture: CircleAvatar(
                      onBackgroundImageError: ((obj, stackTrack) {}),
                      backgroundColor: Colors.black45,
                      backgroundImage: NetworkImage(user.photoURL ?? "")),
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
          user != null
              ? ListTile(
                  title: Text('Account', style: _drawerTileTextStyle()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(actions: [
                                  SignedOutAction((context) {
                                    Navigator.pop(context);
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen(
                                  actions: [
                                    AuthStateChangeAction<SignedIn>(
                                        (context, state) {
                                      Navigator.pop(context);
                                    }),
                                  ],
                                )));
                  },
                )
        ],
      ),
    );
  }
}
