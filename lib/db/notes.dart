import 'package:mr_blue_sky/models/note.dart';
import 'package:sqflite/sqflite.dart';

import 'index.dart';

class NotesSQLite {
  late final Database _db;

  Future open() async {
    _db = await openDatabase('${Databases.notesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
    create table ${Databases.notesDb} ( 
      ${NoteFields.id} integer primary key autoincrement, 
      ${NoteFields.title} text not null,
      ${NoteFields.content} text not null,
      ${NoteFields.editTime} integer not null,
      ${NoteFields.createTime} integer not null,
      ${NoteFields.weatherType} text not null,
      ${NoteFields.uuid} text not null,
      ${NoteFields.hasAttachment} int)
    ''');
    });
  }

  Future<void> insertNote(Note note) async {
    await _db.insert(Databases.notesDb, note.toUUIDMap());
  }

  Future<List<Note>> getAll() async {
    List<Map<String, dynamic>> queryMaps =
        await _db.query(Databases.notesDb, columns: [
      NoteFields.title,
      NoteFields.content,
      NoteFields.editTime,
      NoteFields.createTime,
      NoteFields.weatherType,
      NoteFields.uuid,
      NoteFields.hasAttachment
    ]);

    List<Note> notes = [];
    for (var map in queryMaps) {
      notes.add(Note.fromDB(map[NoteFields.uuid], map));
    }

    return notes;
  }

  Future<int> delete(String uuid) async {
    return await _db.delete(Databases.notesDb,
        where: '${NoteFields.uuid} = ?', whereArgs: [uuid]);
  }

  Future<int> clear() async {
    return await _db.delete(Databases.notesDb, where: null);
  }

  Future<int> update(Note note) async {
    return await _db.update(Databases.notesDb, note.toUUIDMap(),
        where: '${NoteFields.uuid} = ?', whereArgs: [note.uuid]);
  }

  Future<void> close() async => _db.close();
}
