import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:mime_type/mime_type.dart';

import 'asset_entity.dart';
import 'auth.dart';
import 'dio_client.dart';
import 'encrypt.dart';

class Client {
  static Client? _instance;

  factory Client() => _instance!;

  final String endpoint;
  final String bucketName;
  final Function? tokenGetter;

  Client._(
    this.endpoint,
    this.bucketName,
    this.tokenGetter,
  );

  static void init(
      {String? stsUrl,
      required String ossEndpoint,
      required String bucketName,
      String Function()? tokenGetter}) {
    assert(stsUrl != null || tokenGetter != null);
    final tokenGet = tokenGetter ??
        () async {
          final response = await RestClient.getInstance().get<String>(stsUrl!);
          return response.data!;
        };
    _instance = Client._(ossEndpoint, bucketName, tokenGet);
  }

  Auth? _auth;
  String? _expire;

  /// get auth information from sts server
  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      final resp = await tokenGetter!();
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
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance()
        .get(request.url, options: Options(headers: request.headers));
  }

  /// download object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [savePath] is where we save the object(file) that download from oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response> downloadObject(String fileKey, String savePath,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return await RestClient.getInstance().download(request.url, savePath,
        options: Options(headers: request.headers));
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObject(List<int> fileData, String fileKey,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final Map<String, String> headers = {
      'content-md5': EncryptUtil.md5File(fileData),
      'content-type': mime(fileKey) ?? "image/png",
    };
    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance().put(
      request.url,
      data: MultipartFile.fromBytes(fileData).finalize(),
      options: Options(headers: request.headers),
    );
  }

  /// upload object(files) to oss server
  /// [assetEntities] is list of files need to be uploaded to oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<List<Response<dynamic>>> putObjects(List<AssetEntity> assetEntities,
      {String? bucketName}) async {
    final uploads = assetEntities.map((file) async => await putObject(file.bytes, file.filename)).toList();
    return await Future.wait(uploads);
  }

  /// delete object from oss
  Future<Response<dynamic>> deleteObject(String fileKey,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(
        url, 'DELETE', {}, {'content-type': Headers.jsonContentType});
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance()
        .delete(request.url, options: Options(headers: request.headers));
  }

  /// delete objects from oss
  Future<List<Response<dynamic>>> deleteObjects(List<String> keys,
      {String? bucketName}) async {
    final deletes = keys.map((fileKey) async => await deleteObject(fileKey)).toList();
    return await Future.wait(deletes);
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
