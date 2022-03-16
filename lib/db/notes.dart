import 'package:mr_blue_sky/models/note.dart';
import 'package:sqflite/sqflite.dart';

import 'index.dart';

class NotesProvider {
  final columnId = '_id';
  final columnTitle = 'title';
  final columnContent = 'content';
  final columnEditTime = 'editTimestamp';
  final columnCreateTime = 'creationTimestamp';
  final columnWeatherType = 'weatherType';
  final columnUuid = 'uuid';

  late Database db;

  Future open() async {
    db = await openDatabase('${Databases.notesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  create table ${Databases.notesDb} ( 
    $columnId integer primary key autoincrement, 
    $columnTitle text not null,
    $columnContent text not null,
    $columnEditTime integer not null,
    $columnCreateTime integer not null,
    $columnWeatherType text not null,
    $columnUuid text not null)
  ''');
    });
  }

  Future<void> insertNote(Note note) async {
    await db.insert(Databases.notesDb, note.toUUIDMap());
  }

  Future<List<Note>> getAll() async {
    List<Map<String, dynamic>> queryMaps =
        await db.query(Databases.notesDb, columns: [
      columnTitle,
      columnContent,
      columnEditTime,
      columnCreateTime,
      columnWeatherType,
      columnUuid
    ]);

    List<Note> notes = [];
    for (var map in queryMaps) {
      notes.add(Note.fromRTDB(map[columnUuid], map));
    }

    return notes;
  }

  Future<int> delete(String uuid) async {
    return await db
        .delete(Databases.notesDb, where: '$columnUuid = ?', whereArgs: [uuid]);
  }

  Future<int> clear() async {
    return await db.delete(Databases.notesDb, where: null);
  }

  Future<int> update(Note note) async {
    return await db.update(Databases.notesDb, note.toUUIDMap(),
        where: '$columnUuid = ?', whereArgs: [note.uuid]);
  }

  Future<void> close() async => db.close();
}
