class HttpRequest {
  final String _url;
  final String method;
  final Map<String, dynamic> param;
  final Map<String, String> headers;

  HttpRequest(this._url, this.method, this.param, this.headers);

  String get url {
    final urlString =
        param.entries.map((entry) => "${entry.key}=${entry.value}").join("&");
    return urlString.isEmpty ? _url : "$_url?$urlString";
  }
}
