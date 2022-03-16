import 'package:mr_blue_sky/api/iqair/city.dart';
import 'package:sqflite/sqflite.dart';

import 'index.dart';

class CitiesCacheProvider {
  final columnId = '_id';
  final columnCountry = 'country';
  final columnState = 'state';
  final columnCity = 'city';

  late Database db;

  Future open() async {
    db = await openDatabase('${Databases.citiesDb}.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  create table ${Databases.citiesDb} ( 
    $columnId integer primary key autoincrement, 
    $columnCountry text not null,
    $columnState text not null,
    $columnCity text not null)
  ''');
    });
  }

  Future<void> addCities(List<City> cities) async {
    Batch batch = db.batch();
    for (City city in cities) {
      batch.insert(Databases.citiesDb, {
        columnCountry: city.country,
        columnState: city.state,
        columnCity: city.city
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<City>> getCities(String country, String state) async {
    List<Map> queryMaps = await db.query(Databases.citiesDb,
        where: '$columnCountry = ? and $columnState = ?',
        whereArgs: [country, state],
        columns: [columnCity]);

    List<City> cities = [];
    for (var map in queryMaps) {
      cities.add(City(country, state, map[columnCity]));
    }

    return cities;
  }

  Future<void> close() async => db.close();
}
