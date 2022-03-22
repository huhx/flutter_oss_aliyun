import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:mime_type/mime_type.dart';

import 'auth.dart';
import 'dio_client.dart';
import 'encrypt.dart';

class Client {
  static Client? _instance;

  factory Client() => _instance!;

  final String stsRequestUrl;
  final String endpoint;
  final String bucketName;
  final Function(String) tokenGetter;

  Client._(
    this.stsRequestUrl,
    this.endpoint,
    this.bucketName,
    this.tokenGetter,
  );

  static void init({
    required String stsUrl,
    required String ossEndpoint,
    required String bucketName,
  }) {
    _instance = Client._(stsUrl, ossEndpoint, bucketName, (url) async {
      final response = await RestClient.getInstance().get<String>(url);
      return response.data!;
    });
  }

  Auth? _auth;
  String? _expire;

  /// get auth information from sts server
  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      final resp = await tokenGetter(stsRequestUrl);
      final respMap = jsonDecode(resp);
      _auth = Auth(respMap['AccessKeyId'], respMap['AccessKeySecret'],
          respMap['SecurityToken']);
      _expire = respMap['Expiration'];
    }
    return _auth!;
  }

  /// get object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> getObject(String fileKey,
      {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final url = "https://$bucketName.$endpoint/$fileKey";
    var request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucketName, fileKey);

    return RestClient.getInstance()
        .get(request.url, options: Options(headers: request.headers));
  }

  /// download object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [savePath] is where we save the object(file) that download from oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response> downloadObject(String fileKey, String savePath,
      {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final url = "https://$bucketName.$endpoint/$fileKey";
    var request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucketName, fileKey);

    return await RestClient.getInstance().download(request.url, savePath,
        options: Options(headers: request.headers));
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObject(List<int> fileData, String fileKey,
      {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final headers = {
      'content-md5': EncryptUtil.md5File(fileData),
      'content-type': mime(fileKey),
    };
    final url = "https://$bucketName.$endpoint/$fileKey";
    final request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucketName, fileKey);

    return RestClient.getInstance().request(
      request.url,
      data: MultipartFile.fromBytes(fileData).finalize(),
      options: Options(headers: request.headers, method: request.method),
    );
  }

  /// delete object from oss
  Future<Response<dynamic>> deleteObject(String fileKey,
      {String? bucketName}) async {
    bucketName ??= this.bucketName;
    final auth = await _getAuth();

    final url = "https://$bucketName.$endpoint/$fileKey";
    final request = HttpRequest(
        url, 'DELETE', {}, {'content-type': 'application/json; charset=utf-8'});
    auth.sign(request, bucketName, fileKey);

    return RestClient.getInstance()
        .delete(request.url, options: Options(headers: request.headers));
  }

  /// whether auth is valid or not
  bool _isNotAuthenticated() {
    return _auth == null || _isExpired();
  }

  /// whether the auth is expired or not
  bool _isExpired() {
    return _expire == null || DateTime.now().isAfter(DateTime.parse(_expire!));
  }
}
