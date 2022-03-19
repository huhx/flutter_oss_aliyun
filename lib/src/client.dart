import 'dart:convert';

import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:mime_type/mime_type.dart';

import 'auth.dart';
import 'encrypt.dart';

class Client {
  final String stsRequestUrl;
  final String endpoint;
  final Function(String) tokenGetter;

  Client(this.stsRequestUrl, this.endpoint, this.tokenGetter);

  Auth? _auth;
  String? _expire;

  Future<Client> getAuth() async {
    if (_isNotAuthenticated()) {
      final resp = await tokenGetter(stsRequestUrl);
      final respMap = jsonDecode(resp);
      _auth = Auth(respMap['AccessKeyId'], respMap['AccessKeySecret'], respMap['SecurityToken']);
      _expire = respMap['Expiration'];
    }
    return this;
  }

  HttpRequest getObject(String bucketName, String fileKey) {
    final url = "https://$bucketName.$endpoint/$fileKey";
    var req = HttpRequest(url, 'GET', {}, {});
    _auth!.sign(req, bucketName, fileKey);
    return req;
  }

  HttpRequest putObject(List<int> fileData, String bucketName, String fileKey) {
    final headers = {
      'content-md5': EncryptUtil.md5File(fileData),
      'content-type': mime(fileKey),
    };
    final url = "https://$bucketName.$endpoint/$fileKey";
    HttpRequest req = HttpRequest(url, 'PUT', {}, headers);
    _auth!.sign(req, bucketName, fileKey);
    req.fileData = fileData;
    return req;
  }

  HttpRequest deleteObject(String bucketName, String fileKey) {
    final url = "https://$bucketName.$endpoint/$fileKey";
    final req = HttpRequest(url, 'DELETE', {}, {});
    _auth!.sign(req, bucketName, fileKey);
    return req;
  }

  bool _isNotAuthenticated() {
    return _auth == null || _isExpired();
  }

  bool _isExpired() {
    return _expire == null || DateTime.now().isAfter(DateTime.parse(_expire!));
  }
}
