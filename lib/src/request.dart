import 'request_option.dart';

class HttpRequest {
  final String _url;
  final String method;
  final Map<String, dynamic> param;
  final Map<String, dynamic> headers;
  final PutRequestOption? option;

  HttpRequest(
    this._url,
    this.method,
    this.param,
    this.headers, {
    this.option,
  });

  String get url {
    final urlString =
        param.entries.map((entry) => "${entry.key}=${entry.value}").join("&");
    return urlString.isEmpty ? _url : "$_url?$urlString";
  }
}
