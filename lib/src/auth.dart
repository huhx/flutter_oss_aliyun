import 'dart:io';

import 'package:flutter_oss_aliyun/src/request.dart';

import 'encrypt.dart';

class Auth {
  final String accessKey;
  final String accessSecret;
  final String secureToken;

  Auth(
    this.accessKey,
    this.accessSecret,
    this.secureToken,
  );

  /// access aliyun need authenticated, this is the implementation refer to the official document.
  /// [req] include the request headers information that use for auth.
  /// [bucket] is the name of bucket used in aliyun oss
  /// [key] is the object name in aliyun oss, alias the 'filepath/filename'
  void sign(HttpRequest req, String bucket, String key) {
    req.headers['date'] = HttpDate.format(DateTime.now());
    req.headers['x-oss-security-token'] = secureToken;
    final String signature = _makeSignature(req, bucket, key);
    req.headers['Authorization'] = "OSS $accessKey:$signature";
  }

  /// the signature of file
  /// [expires] expired time (seconds)
  /// [bucket] is the name of bucket used in aliyun oss
  /// [key] is the object name in aliyun oss, alias the 'filepath/filename'
  String getSignature(int expires, String bucket, String key) {
    final String stringToSign = [
      "GET",
      "",
      "",
      expires,
      "${_getResourceString(bucket, key)}?security-token=$secureToken"
    ].join("\n");
    return Uri.encodeFull(EncryptUtil.hmacSign(accessSecret, stringToSign))
        .replaceAll("+", "%2B");
  }

  /// sign the string use hmac
  String _makeSignature(HttpRequest req, String bucket, String key) {
    final String contentMd5 = req.headers['content-md5'] ?? '';
    final String contentType = req.headers['content-type'] ?? '';
    final String date = req.headers['date'] ?? '';
    final String headerString = _getHeaderString(req);
    final String resourceString = _getResourceString(bucket, key);
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
  String _getResourceString(String bucket, String fileKey) {
    String path = "/";
    if (bucket.isNotEmpty) path += "$bucket/";
    if (fileKey.isNotEmpty) path += fileKey;
    return path;
  }
}
