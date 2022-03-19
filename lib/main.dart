import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:mr_blue_sky/firebase/values.dart';
import 'package:mr_blue_sky/providers/fav_cities_provider.dart';
import 'package:mr_blue_sky/providers/notes_provider.dart';
import 'package:mr_blue_sky/providers/weather_provider.dart';
import 'package:mr_blue_sky/views/homepage.dart';
import 'package:mr_blue_sky/views/themes.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// Mr. Blue Sky:
/// A Weather and Air Quality monitoring app built with Flutter
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        darkTheme: darkTheme,
        theme: lightTheme,
        home: FutureBuilder(
            future: _firebaseApp,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Scaffold(
                    body: Center(
                        child: Text("Firebase could not be initialised.")));
              } else if (snapshot.hasData) {
                // Configure Auth providers
                FlutterFireUIAuth.configureProviders([
                  const PhoneProviderConfiguration(),
                  const GoogleProviderConfiguration(clientId: googleClientId)
                ]);
                FirebaseDatabase.instance.setPersistenceEnabled(true);
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider<WeatherProvider>(
                        create: (_) => WeatherProvider()),
                    ChangeNotifierProvider<NotesProvider>(
                        create: (_) => NotesProvider()),
                    ChangeNotifierProvider<FavCitiesProvider>(
                        create: (_) => FavCitiesProvider())
                  ],
                  child: const MyHomePage(title: 'Mr. Blue Sky'),
                );
              } else {
                // Display loading indicator
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
            })));
  }
}
