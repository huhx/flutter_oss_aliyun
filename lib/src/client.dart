import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:mime_type/mime_type.dart';

import 'auth.dart';
import 'encrypt.dart';

class Client {
  static Client? _instance;

  factory Client() => _instance!;

  final String stsRequestUrl;
  final String endpoint;
  final String bucketName;
  final Function(String) tokenGetter;

  Client._(this.stsRequestUrl, this.endpoint, this.bucketName, this.tokenGetter);

  static void init({
    required String stsUrl,
    required String ossEndpoint,
    required String bucketName,
  }) {
    _instance = Client._(stsUrl, ossEndpoint, bucketName, (url) async {
      final response = await Dio().get<String>(url);
      return response.data!;
    });
  }

  Auth? _auth;
  String? _expire;

  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      final resp = await tokenGetter(stsRequestUrl);
      final respMap = jsonDecode(resp);
      _auth = Auth(respMap['AccessKeyId'], respMap['AccessKeySecret'], respMap['SecurityToken']);
      _expire = respMap['Expiration'];
    }
    return _auth!;
  }

  Future<Response<dynamic>> getObject(String fileKey, {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final url = "https://$bucketName.$endpoint/$fileKey";
    var request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucketName, fileKey);

    return Dio().request(
      request.url,
      options: Options(headers: request.headers, method: request.method),
    );
  }

  Future<Response> downloadObject(String fileKey, String savePath, {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final url = "https://$bucketName.$endpoint/$fileKey";
    var request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucketName, fileKey);

    return await Dio().download(request.url, savePath, options: Options(headers: request.headers));
  }

  Future<Response<dynamic>> putObject(List<int> fileData, String fileKey, {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final headers = {
      'content-md5': EncryptUtil.md5File(fileData),
      'content-type': mime(fileKey),
    };
    final url = "https://$bucketName.$endpoint/$fileKey";
    HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucketName, fileKey);
    return Dio().request(
      request.url,
      data: MultipartFile.fromBytes(fileData).finalize(),
      options: Options(headers: request.headers, method: request.method),
    );
  }

  bool _isNotAuthenticated() {
    return _auth == null || _isExpired();
  }

  bool _isExpired() {
    return _expire == null || DateTime.now().isAfter(DateTime.parse(_expire!));
  }
}
