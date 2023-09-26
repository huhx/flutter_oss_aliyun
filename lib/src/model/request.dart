class HttpRequest {
  const HttpRequest(
    this._url,
    this.method,
    this.param,
    this.headers,
  );

  final String _url;
  final String method;
  final Map<String, dynamic> param;
  final Map<String, dynamic> headers;

  String get url {
    final String queryString =
        param.entries.map((entry) => "${entry.key}=${entry.value}").join("&");
    return queryString.isEmpty ? _url : "$_url?$queryString";
  }

  factory HttpRequest.get(String url,
      {Map<String, dynamic>? parameters, Map<String, dynamic>? headers}) {
    return HttpRequest(url, 'GET', parameters ?? {}, headers ?? {});
  }
}
