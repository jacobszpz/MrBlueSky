import 'package:flutter/material.dart';

class MySnackBars {
  static const String _weatherNotReadyMsg = 'Weather data not ready';
  static const String _rateIssueMsg = 'The call rate limit has been reached';
  static const String _networkIssueMsg = 'The weather API could not be reached';

  static SnackBar weatherNotReady() => _createSnackBar(_weatherNotReadyMsg);
  static SnackBar networkIssue() => _createSnackBar(_networkIssueMsg);
  static SnackBar rateIssue() => _createSnackBar(_rateIssueMsg);

  static _createSnackBar(String msg) {
    return SnackBar(
      content: Text(msg),
    );
  }
}
