import 'dart:convert';

class City {
  final String _state;
  final String _country;
  final String _city;
  City(this._country, this._state, this._city);

  factory City.fromBase64(String encoded) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var decoded = stringToBase64.decode(encoded);
    var parts = decoded.split(";");
    return City(parts[0], parts[1], parts[2]);
  }

  String get state => _state;
  String get country => _country;
  String get city => _city;

  Map<String, dynamic> toMap() {
    return {'city': _city, 'country': _country, 'state': _state};
  }

  @override
  String toString() {
    return '$_city, $_country';
  }

  String get toBase64 {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode("$_country;$_state;$_city");
  }
}
