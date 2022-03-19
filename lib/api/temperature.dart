class Temperature {
  final num _celsius;
  Temperature.celsius(this._celsius);

  num get f {
    return (_celsius * 1.8) + 32;
  }

  num get c {
    return _celsius;
  }

  final String cSymbol = '°C';
  final String fSymbol = '°F';
  @override
  String toString() {
    return c.toString() + cSymbol;
  }
}
