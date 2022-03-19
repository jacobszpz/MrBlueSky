import 'package:mr_blue_sky/api/state.dart';
import 'package:sqflite/sqflite.dart';

import 'index.dart';

class StatesCacheProvider {
  final columnId = '_id';
  final columnCountry = 'country';
  final columnState = 'state';

  late Database db;

  Future open() async {
    db = await openDatabase('${Databases.statesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  create table ${Databases.statesDb} ( 
    $columnId integer primary key autoincrement, 
    $columnCountry text not null,
    $columnState text not null)
  ''');
    });
  }

  Future<void> addStates(List<State> states) async {
    Batch batch = db.batch();
    for (State state in states) {
      batch.insert(Databases.statesDb,
          {columnCountry: state.country, columnState: state.state});
    }

    await batch.commit(noResult: true);
  }

  Future<List<State>> getStates(String country) async {
    List<Map> queryMaps = await db.query(Databases.statesDb,
        where: '$columnCountry = ?',
        whereArgs: [country],
        columns: [columnState]);

    List<State> states = [];
    for (var map in queryMaps) {
      states.add(State(country, map[columnState]));
    }

    return states;
  }

  Future<void> close() async => db.close();
}
