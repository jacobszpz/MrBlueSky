import 'package:sqflite/sqflite.dart';

import 'index.dart';

class CountriesProvider {
  final columnId = '_id';
  final columnCountry = 'country';
  Database? db;

  Future open() async {
    db = await openDatabase('${Databases.countriesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  create table ${Databases.countriesDb} ( 
    $columnId integer primary key autoincrement, 
    $columnCountry text not null)
  ''');
    });
  }

  Future<void> insertCountries(List<String> countries) async {
    Batch batch = db!.batch();
    for (String country in countries) {
      batch.insert(Databases.countriesDb, {columnCountry: country});
    }

    await batch.commit(noResult: true);
  }

  Future<List<String>> getAll() async {
    List<Map> queryMaps = await db!
        .query(Databases.countriesDb, columns: [columnId, columnCountry]);

    List<String> countries = [];
    for (var map in queryMaps) {
      countries.add(map[columnCountry]);
    }

    return countries;
  }

  Future<void> close() async => db!.close();
}
