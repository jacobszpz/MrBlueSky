/// Represents an error received from the API
class ApiException implements Exception {
  String msg;
  ApiException({this.msg = 'The IQAir API has returned an error'});
}