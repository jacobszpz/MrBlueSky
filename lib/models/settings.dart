enum TempUnits { C, F }
enum APISource { iqAir }

class Settings {
  TempUnits _unit = TempUnits.C;
  APISource _api = APISource.iqAir;
  bool _showFavCity = false;

  TempUnits get unit => _unit;

  set unit(TempUnits value) {
    _unit = value;
  }

  APISource get api => _api;

  set api(APISource value) {
    _api = value;
  }

  bool get showFavCity => _showFavCity;

  set showFavCity(bool value) {
    _showFavCity = value;
  }
}
