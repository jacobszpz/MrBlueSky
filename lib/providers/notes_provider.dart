import 'dart:async';
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mr_blue_sky/db/notes.dart';
import 'package:mr_blue_sky/firebase/values.dart';
import 'package:mr_blue_sky/models/note.dart';
import 'package:mr_blue_sky/models/sort_orders.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  User? firebaseUser;
  late Future openDB;

  final NotesSQLite _sqlDB = NotesSQLite();
  final _db =
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: dbURL)
          .ref();

  static const notesPath = 'notes';

  NotesProvider() {
    openDB = _sqlDB.open();
    _getFromLocal().then((value) => notifyListeners());
    _listenToNotes();
  }

  Future _getFromLocal() async {
    await openDB;
    _sqlDB.getAll().then((sqlNotes) {
      _notes.addAll(sqlNotes);
    });
  }

  late StreamSubscription<DatabaseEvent> _notesStream;

  List<Note> get notes => _notes;

  DatabaseReference _notesRef(String userUID) {
    return _db.child(sharedPrefsPath).child(userUID).child(notesPath);
  }

  Future _listenToNotes() async {
    FirebaseAuth.instance.authStateChanges().listen((userStream) {
      firebaseUser = userStream;

      if (userStream == null) {
        _notesStream.cancel();
      } else {
        _notesStream = _notesRef(userStream.uid).onValue.listen((event) {
          _notes.clear();
          _notes.addAll(_getFromSnapshot(event.snapshot));
          notifyListeners();
        });

        // Copy all notes to firebase
        openDB.then((_) {
          _sqlDB.getAll().then((notes) {
            for (Note note in notes) {
              _notesRef(userStream.uid).child(note.uuid).set(note.toMap());
              _sqlDB.clear();
            }
          });
        });
      }
    });
  }

  List<Note> _getFromSnapshot(DataSnapshot snapshot) {
    List<Note> notes = [];
    Object notesObj = snapshot.value ?? <Object, Object>{};
    var notesObjMap = notesObj as Map<Object?, Object?>;
    Map<String, dynamic> dbNotes = notesObjMap.cast<String, dynamic>();

    for (var noteEntry in dbNotes.entries) {
      Map<String, dynamic> noteMap = noteEntry.value.cast<String, dynamic>();
      notes.add(Note.fromRTDB(noteEntry.key, noteMap));
    }

    notes.sort(((a, b) => a.creationTimestamp.compareTo(b.creationTimestamp)));
    return notes;
  }

  Future removeAt(int index) async {
    if (index < _notes.length) {
      var note = _notes.removeAt(index);
      final user = firebaseUser;

      if (user != null) {
        _notesRef(user.uid).child(note.uuid).remove();
      } else {
        _sqlDB.delete(note.uuid);
      }

      notifyListeners();
    }
  }

  Future sort(SortingOrder order) async {
    int Function(Note a, Note b) sortingFunction =
        ((a, b) => a.creationTimestamp.compareTo(b.creationTimestamp));

    if (order == SortingOrder.alphabet) {
      sortingFunction =
          ((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    _notes.sort(sortingFunction);
    notifyListeners();
  }

  Future edit(int index, Note note) async {
    final user = firebaseUser;

    if (user != null) {
      _notesRef(user.uid).child(note.uuid).set(note.toMap());
    } else {
      _sqlDB.update(note);
    }

    _notes[index] = note;
    notifyListeners();
  }

  Future add(Note note) async {
    if (note.isNotEmpty) {
      final user = firebaseUser;
      if (user != null) {
        _notesRef(user.uid).child(note.uuid).set(note.toMap());
      } else {
        _sqlDB.insertNote(note);
      }
      _notes.add(note);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notesStream.cancel();
    super.dispose();
  }
}
