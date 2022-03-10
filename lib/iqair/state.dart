class State {
  final String _state;
  final String _country;
  State(this._country, this._state);

  String get state => _state;
  String get country => _country;

  Map<String, dynamic> toMap() {
    return {
      'country': _country,
      'state': _state
    };
  }

  @override
  String toString() {
    return '$_state, $_country';
  }
}