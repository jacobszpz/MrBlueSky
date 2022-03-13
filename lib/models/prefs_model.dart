import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mr_blue_sky/models/settings.dart';

class PrefsModel extends ChangeNotifier {
  Settings? _settings;
  final _db = FirebaseDatabase.instance.ref();

  Settings? get settings => _settings;

  static const sharedPrefsPath = "sharedPrefs";
  //static const aj = "";

  late StreamSubscription<DatabaseEvent> _prefsStream;

  PrefsModel() {
    _listenToPrefs();
  }
  @override
  void dispose() {
    super.dispose();
    _prefsStream.cancel();
  }

  _listenToPrefs() {
    _prefsStream = _db.child(sharedPrefsPath).onValue.listen((event) {
      notifyListeners();
    });
  }
}
