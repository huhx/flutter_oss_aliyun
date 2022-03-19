import 'dart:io';

import 'package:flutter_oss_aliyun/src/request.dart';

import 'encrypt.dart';

class Auth {
  final String accessKey;
  final String accessSecret;
  final String secureToken;

  Auth(this.accessKey, this.accessSecret, this.secureToken);

  void sign(HttpRequest req, String bucket, String key) {
    req.headers['date'] = HttpDate.format(DateTime.now());
    req.headers['x-oss-security-token'] = secureToken;
    final signature = _makeSignature(req, bucket, key);
    req.headers['Authorization'] = "OSS $accessKey:$signature";
  }

  String _makeSignature(HttpRequest req, String bucket, String key) {
    final stringToSign = _getStringToSign(req, bucket, key);
    return EncryptUtil.hmacSign(accessSecret, stringToSign);
  }

  String _getStringToSign(HttpRequest req, String bucket, String key) {
    final contentMd5 = req.headers['content-md5'] ?? '';
    final contentType = req.headers['content-type'] ?? '';
    final date = req.headers['date'] ?? '';
    final headerString = _getHeaderString(req) ?? '';
    final resourceString = _getResourceString(req, bucket, key);
    return [req.method, contentMd5, contentType, date, headerString, resourceString].join("\n");
  }

  String _getResourceString(HttpRequest req, String bucket, String fileKey) {
    String path = "/";
    if (bucket.isNotEmpty) path += "$bucket/";
    if (fileKey.isNotEmpty) path += fileKey;
    return path;
  }

  String? _getHeaderString(HttpRequest req) {
    final ossHeaders = req.headers.keys.where((key) => key.toLowerCase().startsWith('x-oss-')).toList();
    if (ossHeaders.isEmpty) return '';
    ossHeaders.sort((s1, s2) => s1.compareTo(s2));
    return ossHeaders.map((key) => "$key:${req.headers[key]}").join("\n");
  }
}
