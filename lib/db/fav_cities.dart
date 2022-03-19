import 'package:mr_blue_sky/models/fav_city.dart';
import 'package:sqflite/sqflite.dart';

import 'index.dart';

class FavCitiesSQLite {
  late final Database _db;

  Future open() async {
    _db = await openDatabase('${Databases.favCitiesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  create table ${Databases.favCitiesDb} ( 
    ${FavCityFields.id} integer primary key autoincrement, 
    ${FavCityFields.hash} text not null,
    ${FavCityFields.dateAdded} integer not null,
    ${FavCityFields.lat} real not null,
    ${FavCityFields.long} real not null)
  ''');
    });
  }

  Future<void> insertCity(FavCity fav) async {
    await _db.insert(Databases.favCitiesDb, fav.toDBMap());
  }

  Future<List<FavCity>> getAll() async {
    List<Map<String, dynamic>> queryMaps =
        await _db.query(Databases.favCitiesDb, columns: [
      FavCityFields.hash,
      FavCityFields.dateAdded,
      FavCityFields.lat,
      FavCityFields.long
    ]);

    List<FavCity> favs = [];
    for (var map in queryMaps) {
      favs.add(FavCity.fromMap(map[FavCityFields.hash], map));
    }

    return favs;
  }

  Future<int> delete(String hash) async {
    return await _db.delete(Databases.favCitiesDb,
        where: '${FavCityFields.hash} = ?', whereArgs: [hash]);
  }

  Future<int> clear() async {
    return await _db.delete(Databases.favCitiesDb, where: null);
  }

  Future<void> close() async => _db.close();
}
