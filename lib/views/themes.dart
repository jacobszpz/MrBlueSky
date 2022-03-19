import 'package:flutter/material.dart';

Color? blueSkyColor = Colors.blue[500];
Color? deepSkyColor = Colors.deepPurple[900];

ThemeData darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            accentColor: deepSkyColor,
            primaryColorDark: deepSkyColor,
            primarySwatch: Colors.blue,
            cardColor: deepSkyColor))
    .copyWith(useMaterial3: true);

ThemeData lightTheme = ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.light,
            cardColor: blueSkyColor,
            primaryColorDark: deepSkyColor,
            primarySwatch: Colors.blue))
    .copyWith(useMaterial3: true);
