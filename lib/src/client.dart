import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:flutter_oss_aliyun/src/request_option.dart';
import 'package:mime_type/mime_type.dart';

import 'asset_entity.dart';
import 'auth.dart';
import 'dio_client.dart';
import 'enums.dart';
import 'option_extension.dart';

class Client {
  static Client? _instance;

  factory Client() => _instance!;

  final String endpoint;
  final String bucketName;
  final Future<String> Function() tokenGetter;
  static late Dio _dio;

  Client._(
    this.endpoint,
    this.bucketName,
    this.tokenGetter,
  );

  static void init({
    String? stsUrl,
    required String ossEndpoint,
    required String bucketName,
    Future<String> Function()? tokenGetter,
    Dio? dio,
  }) {
    assert(stsUrl != null || tokenGetter != null);
    _dio = dio ?? RestClient.getInstance();

    final tokenGet = tokenGetter ??
        () async {
          final response = await _dio.get<String>(stsUrl!);
          return response.data!;
        };
    _instance = Client._(ossEndpoint, bucketName, tokenGet);
  }

  Auth? _auth;
  String? _expire;

  /// get object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> getObject(
    String fileKey, {
    String? bucketName,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get signed url from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  /// [expireSeconds] is optional, default expired time are 60 seconds
  Future<String> getSignedUrl(
    String fileKey, {
    String? bucketName,
    int expireSeconds = 60,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();
    final int expires =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor() + expireSeconds;

    final String url = "https://$bucket.$endpoint/$fileKey";
    final Map<String, dynamic> params = {
      "OSSAccessKeyId": auth.accessKey,
      "Expires": expires,
      "Signature": auth.getSignature(expires, bucket, fileKey),
      "security-token": auth.secureToken.replaceAll("+", "%2B")
    };
    final String queryString =
        params.entries.map((entry) => "${entry.key}=${entry.value}").join("&");

    return "$url?$queryString";
  }

  /// get signed url from oss server
  /// [fileKeys] list of object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  /// [expireSeconds] is optional, default expired time are 60 seconds
  Future<Map<String, String>> getSignedUrls(
    List<String> fileKeys, {
    String? bucketName,
    int expireSeconds = 60,
  }) async {
    return {
      for (final String fileKey in fileKeys.toSet())
        fileKey: await getSignedUrl(
          fileKey,
          bucketName: bucketName,
          expireSeconds: expireSeconds,
        )
    };
  }

  /// list objects from oss server
  /// [parameters] parameters for filter, refer to: https://help.aliyun.com/document_detail/31957.html
  Future<Response<dynamic>> listBuckets(
    Map<String, dynamic> parameters, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint";
    final HttpRequest request = HttpRequest(url, 'GET', parameters, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// list objects from oss server
  /// [parameters] parameters for filter, refer to: https://help.aliyun.com/document_detail/187544.html
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> listObjects(
    Map<String, dynamic> parameters, {
    String? bucketName,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint";
    parameters["list-type"] = 2;
    final HttpRequest request = HttpRequest(url, 'GET', parameters, {});
    auth.sign(request, bucket, "");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get bucket info
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> getBucketInfo({
    String? bucketName,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint?bucketInfo";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?bucketInfo");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get bucket stat
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> getBucketStat({
    String? bucketName,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint?stat";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?stat");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// download object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [savePath] is where we save the object(file) that download from oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response> downloadObject(
    String fileKey,
    String savePath, {
    String? bucketName,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return await _dio.download(
      request.url,
      savePath,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObject(
    List<int> fileData,
    String fileKey, {
    PutRequestOption? option,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final Auth auth = await _getAuth();

    final MultipartFile multipartFile = MultipartFile.fromBytes(
      fileData,
      filename: fileKey,
    );

    final Map<String, dynamic> headers = {
      'content-type': mime(fileKey) ?? "image/png",
      'content-length': multipartFile.length,
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };
    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, fileKey);

    return _dio.put(
      request.url,
      data: _chunkFile(multipartFile),
      options: Options(headers: request.headers),
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [file] is the file that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObjectFile(
    File file, {
    PutRequestOption? option,
    String? fileKey,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final String filename =
        fileKey ?? file.path.split(Platform.pathSeparator).last;
    final Auth auth = await _getAuth();

    final MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: filename,
    );

    final Map<String, dynamic> headers = {
      'content-type': mime(fileKey) ?? "image/png",
      'content-length': multipartFile.length,
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };
    final String url = "https://$bucket.$endpoint/$filename";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, filename);

    return _dio.put(
      request.url,
      data: multipartFile.finalize(),
      options: Options(headers: request.headers),
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(files) to oss server
  /// [assetEntities] is list of files need to be uploaded to oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<List<Response<dynamic>>> putObjectFiles(
    List<AssetFileEntity> assetEntities,
  ) async {
    final uploads = assetEntities
        .map((fileEntity) async => await putObjectFile(
              fileEntity.file,
              fileKey: fileEntity.filename,
              option: fileEntity.option,
            ))
        .toList();
    return await Future.wait(uploads);
  }

  /// upload object(files) to oss server
  /// [assetEntities] is list of files need to be uploaded to oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<List<Response<dynamic>>> putObjects(
    List<AssetEntity> assetEntities,
  ) async {
    final uploads = assetEntities
        .map((file) async => await putObject(
              file.bytes,
              file.filename,
              option: file.option,
            ))
        .toList();
    return await Future.wait(uploads);
  }

  /// get object metadata
  Future<Response<dynamic>> getObjectMeta(
    String fileKey, {
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'HEAD', {}, {});
    auth.sign(request, bucket, fileKey);

    return _dio.head(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// get all supported regions
  Future<Response<dynamic>> getAllRegions() async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint/?regions";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// get bucket acl
  Future<Response<dynamic>> getBucketAcl({
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?acl";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?acl");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// get bucket policy
  Future<Response<dynamic>> getBucketPolicy({
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?policy";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?policy");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// delete bucket policy
  Future<Response<dynamic>> deleteBucketPolicy({
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?policy";
    final HttpRequest request = HttpRequest(url, 'DELETE', {}, {
      'content-type': Headers.jsonContentType,
    });
    auth.sign(request, bucket, "?policy");

    return _dio.delete(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// put bucket policy
  Future<Response<dynamic>> putBucketPolicy(
    Map<String, dynamic> policy, {
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?policy";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, {
      'content-type': Headers.jsonContentType,
    });
    auth.sign(request, bucket, "?policy");

    return _dio.put(
      data: policy,
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// put bucket acl
  Future<Response<dynamic>> putBucketAcl(
    AclMode aciMode, {
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?acl";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, {
      'content-type': Headers.jsonContentType,
      'x-oss-acl': aciMode.content,
    });
    auth.sign(request, bucket, "?acl");

    return _dio.put(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// get all supported regions
  Future<Response<dynamic>> getRegion(String region) async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint/?regions=$region";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// delete object from oss
  Future<Response<dynamic>> deleteObject(
    String fileKey, {
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'DELETE', {}, {
      'content-type': Headers.jsonContentType,
    });
    auth.sign(request, bucket, fileKey);

    return _dio.delete(
      request.url,
      options: Options(headers: request.headers),
    );
  }

  /// delete objects from oss
  Future<List<Response<dynamic>>> deleteObjects(
    List<String> keys, {
    String? bucketName,
  }) async {
    final deletes = keys
        .map((fileKey) async => await deleteObject(
              fileKey,
              bucketName: bucketName,
            ))
        .toList();
    return await Future.wait(deletes);
  }

  /// get auth information from sts server
  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      final String resp = await tokenGetter();
      final respMap = jsonDecode(resp);
      _auth = Auth(
        respMap['AccessKeyId'],
        respMap['AccessKeySecret'],
        respMap['SecurityToken'],
      );
      _expire = respMap['Expiration'];
    }
    return _auth!;
  }

  /// whether auth is valid or not
  bool _isNotAuthenticated() {
    return _auth == null || _isExpired();
  }

  /// whether the auth is expired or not
  bool _isExpired() {
    return _expire == null || DateTime.now().isAfter(DateTime.parse(_expire!));
  }

  /// chunk multipartFile to stream, chunk size is: 64KB
  Stream<List<int>> _chunkFile(MultipartFile multipartFile) async* {
    final ChunkedStreamReader<int> reader =
        ChunkedStreamReader<int>(multipartFile.finalize());
    while (true) {
      final Uint8List data = await reader.readBytes(64 * 1024);
      if (data.isEmpty) {
        break;
      }
      yield data;
    }
  }
}
