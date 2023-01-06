class HttpRequest {
  final String _url;
  final String method;
  final Map<String, dynamic> param;
  final Map<String, dynamic> headers;

  HttpRequest(
    this._url,
    this.method,
    this.param,
    this.headers,
  );

  String get url {
    final queryString =
        param.entries.map((entry) => "${entry.key}=${entry.value}").join("&");
    return queryString.isEmpty ? _url : "$_url?$queryString";
  }
}
