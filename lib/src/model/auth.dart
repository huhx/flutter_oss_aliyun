import 'package:flutter_oss_aliyun/src/extension/date_extension.dart';
import 'package:flutter_oss_aliyun/src/model/request.dart';
import 'package:flutter_oss_aliyun/src/model/signed_parameters.dart';
import 'package:flutter_oss_aliyun/src/util/encrypt.dart';

class Auth {
  const Auth({
    required this.accessKey,
    required this.accessSecret,
    required this.secureToken,
    required this.expire,
  });

  final String accessKey;
  final String accessSecret;
  final String secureToken;
  final String expire;

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      accessKey: json['AccessKeyId'] as String,
      accessSecret: json['AccessKeySecret'] as String,
      secureToken: json['SecurityToken'] as String,
      expire: json['Expiration'] as String,
    );
  }

  bool get isExpired => DateTime.now().isAfter(DateTime.parse(expire));

  String get encodedToken => secureToken.replaceAll("+", "%2B");

  /// access aliyun need authenticated, this is the implementation refer to the official document.
  /// [req] include the request headers information that use for auth.
  /// [bucket] is the name of bucket used in aliyun oss
  /// [key] is the object name in aliyun oss, alias the 'filepath/filename'
  void sign(HttpRequest req, String bucket, String key) {
    req.headers['x-oss-date'] = DateTime.now().toGMTString();
    req.headers['x-oss-security-token'] = secureToken;
    final String signature = _makeSignature(req, bucket, key);
    req.headers['Authorization'] = "OSS $accessKey:$signature";
  }

  /// the signature of file
  /// [expires] expired time (seconds)
  /// [bucket] is the name of bucket used in aliyun oss
  /// [key] is the object name in aliyun oss, alias the 'filepath/filename'
  String getSignature(
    int expires,
    String bucket,
    String key, {
    Map<String, dynamic>? params,
  }) {
    final String queryString = params == null
        ? ""
        : params.entries
            .where((entry) => entry.key.toLowerCase().startsWith('x-oss-'))
            .map((entry) => "${entry.key}=${entry.value}")
            .join("&");
    final String paramString = queryString.isEmpty ? "" : "&$queryString";

    final String stringToSign = [
      "GET",
      "",
      '',
      expires,
      "${_getResourceString(bucket, key, {})}?security-token=$secureToken$paramString"
    ].join("\n");
    final String signed = EncryptUtil.hmacSign(accessSecret, stringToSign);

    return Uri.encodeFull(signed).replaceAll("+", "%2B");
  }

  /// sign the string use hmac
  String _makeSignature(HttpRequest req, String bucket, String key) {
    final String contentMd5 = req.headers['content-md5'] ?? '';
    final String contentType = req.headers['content-type'] ?? '';
    final String date = req.headers['x-oss-date'] ?? '';
    final String headerString = _getHeaderString(req);
    final String resourceString =
        _getResourceString(bucket, key, req.param, req.oriUrl);
    final String stringToSign = [
      req.method,
      contentMd5,
      contentType,
      date,
      headerString,
      resourceString
    ].join("\n");

    return EncryptUtil.hmacSign(accessSecret, stringToSign);
  }

  /// sign the header information
  String _getHeaderString(HttpRequest req) {
    final List<String> ossHeaders = req.headers.keys
        .where((key) => key.toLowerCase().startsWith('x-oss-'))
        .toList();
    if (ossHeaders.isEmpty) return '';
    ossHeaders.sort((s1, s2) => s1.compareTo(s2));

    return ossHeaders.map((key) => "$key:${req.headers[key]}").join("\n");
  }

  /// sign the resource part information
  String _getResourceString(
    String bucket,
    String fileKey,
    Map<String, dynamic> param, [
    String? url,
  ]) {
    String path = "/";
    if (bucket.isNotEmpty) path += "$bucket/";
    if (fileKey.isNotEmpty) path += fileKey;

    bool hasSuffix = false;

    if (url != null) {
      if (url.lastIndexOf("?") != -1) {
        hasSuffix = true;
        path += "?${url.split("?").last}";
      }
    }

    final String signedParamString = param.keys
        .where((key) => SignParameters.signedParams.contains(key))
        .map((item) => "$item=${param[item]}")
        .join("&");
    if (signedParamString.isNotEmpty) {
      path += "${hasSuffix ? '' : '?'}$signedParamString";
    }

    return path;
  }
}
