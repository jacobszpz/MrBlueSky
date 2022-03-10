class City {
  final String _state;
  final String _country;
  final String _city;
  City(this._country, this._state, this._city);

  String get state => _state;
  String get country => _country;
  String get city => _city;

  Map<String, dynamic> toMap() {
    return {
      'city': _city,
      'country': _country,
      'state': _state
    };
  }

  @override
  String toString() {
    return '$_city, $_country';
  }
}