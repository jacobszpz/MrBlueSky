enum TempUnits { C, F }
enum APISource { iqAir }

class Settings {
  TempUnits unit = TempUnits.C;
  APISource api = APISource.iqAir;
  bool showFavCity = false;
}
