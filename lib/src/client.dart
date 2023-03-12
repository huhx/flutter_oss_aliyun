import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/model/callback.dart';
import 'package:flutter_oss_aliyun/src/client_api.dart';
import 'package:flutter_oss_aliyun/src/model/request.dart';
import 'package:flutter_oss_aliyun/src/model/request_option.dart';
import 'package:mime/mime.dart';

import 'model/asset_entity.dart';
import 'model/auth.dart';
import 'util/dio_client.dart';
import 'model/enums.dart';
import 'extension/option_extension.dart';

class Client implements ClientApi {
  static Client? _instance;

  factory Client() => _instance!;

  final String endpoint;
  final String bucketName;
  final FutureOr<Auth> Function() authGetter;
  static late Dio _dio;

  Client._(
    this.endpoint,
    this.bucketName,
    this.authGetter,
  );

  static void init({
    String? stsUrl,
    required String ossEndpoint,
    required String bucketName,
    FutureOr<Auth> Function()? authGetter,
    Dio? dio,
  }) {
    assert(stsUrl != null || authGetter != null);
    _dio = dio ?? RestClient.getInstance();

    final authGet = authGetter ??
        () async {
          final response = await _dio.get<dynamic>(stsUrl!);
          return Auth.fromJson(response.data!);
        };
    _instance = Client._(ossEndpoint, bucketName, authGet);
  }

  Auth? _auth;

  /// get object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> getObject(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get signed url from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  /// [expireSeconds] is optional, default expired time are 60 seconds
  @override
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
      "security-token": auth.encodedToken
    };
    final HttpRequest request = HttpRequest(url, 'GET', params, {});

    return request.url;
  }

  /// get signed url from oss server
  /// [fileKeys] list of object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  /// [expireSeconds] is optional, default expired time are 60 seconds
  @override
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
  @override
  Future<Response<dynamic>> listBuckets(
    Map<String, dynamic> parameters, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint";
    final HttpRequest request = HttpRequest(url, 'GET', parameters, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// list objects from oss server
  /// [parameters] parameters for filter, refer to: https://help.aliyun.com/document_detail/187544.html
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> listObjects(
    Map<String, dynamic> parameters, {
    String? bucketName,
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get bucket info
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> getBucketInfo({
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint?bucketInfo";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?bucketInfo");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get bucket stat
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> getBucketStat({
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint?stat";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?stat");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// download object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [savePath] is where we save the object(file) that download from oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response> downloadObject(
    String fileKey,
    String savePath, {
    String? bucketName,
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> putObject(
    List<int> fileData,
    String fileKey, {
    CancelToken? cancelToken,
    PutRequestOption? option,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final Auth auth = await _getAuth();

    final MultipartFile multipartFile = MultipartFile.fromBytes(
      fileData,
      filename: fileKey,
    );
    final Callback? callback = option?.callback;

    final Map<String, dynamic> internalHeaders = {
      'content-type': lookupMimeType(fileKey) ?? "application/octet-stream",
      'content-length': multipartFile.length,
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };
    final Map<String, dynamic> externalHeaders = option?.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      if (callback != null) ...callback.toHeaders(),
      ...externalHeaders,
    };

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, fileKey);

    return _dio.put(
      request.url,
      data: _chunkFile(multipartFile),
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [position] next position that append to, default value is 0.
  @override
  Future<Response<dynamic>> appendObject(
    List<int> fileData,
    String fileKey, {
    CancelToken? cancelToken,
    PutRequestOption? option,
    int? position,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final Auth auth = await _getAuth();

    final MultipartFile multipartFile = MultipartFile.fromBytes(
      fileData,
      filename: fileKey,
    );

    final Map<String, dynamic> internalHeaders = {
      'content-type': lookupMimeType(fileKey) ?? "application/octet-stream",
      'content-length': multipartFile.length,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };
    final Map<String, dynamic> externalHeaders = option?.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      ...externalHeaders
    };

    final String url =
        "https://$bucket.$endpoint/$fileKey?append&position=${position ?? 0}";
    final HttpRequest request = HttpRequest(url, 'POST', {}, headers);
    auth.sign(request, bucket, "$fileKey?append&position=${position ?? 0}");

    return _dio.post(
      request.url,
      data: _chunkFile(multipartFile),
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [filepath] is the filepath of the File that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<Response<dynamic>> putObjectFile(
    String filepath, {
    PutRequestOption? option,
    CancelToken? cancelToken,
    String? fileKey,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final String filename = fileKey ?? filepath.split('/').last;
    final Auth auth = await _getAuth();

    final MultipartFile multipartFile = await MultipartFile.fromFile(
      filepath,
      filename: filename,
    );

    final Map<String, dynamic> internalHeaders = {
      'content-type': lookupMimeType(filename) ?? "application/octet-stream",
      'content-length': multipartFile.length,
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };

    final Map<String, dynamic> externalHeaders = option?.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      ...externalHeaders
    };

    final String url = "https://$bucket.$endpoint/$filename";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, filename);

    return _dio.put(
      request.url,
      data: multipartFile.finalize(),
      options: Options(headers: request.headers),
      cancelToken: cancelToken,
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(files) to oss server
  /// [assetEntities] is list of files need to be uploaded to oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<List<Response<dynamic>>> putObjectFiles(
    List<AssetFileEntity> assetEntities, {
    CancelToken? cancelToken,
  }) async {
    final uploads = assetEntities
        .map((fileEntity) async => await putObjectFile(
              fileEntity.filepath,
              fileKey: fileEntity.filename,
              cancelToken: cancelToken,
              option: fileEntity.option,
            ))
        .toList();
    return await Future.wait(uploads);
  }

  /// upload object(files) to oss server
  /// [assetEntities] is list of files need to be uploaded to oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  @override
  Future<List<Response<dynamic>>> putObjects(
    List<AssetEntity> assetEntities, {
    CancelToken? cancelToken,
  }) async {
    final uploads = assetEntities
        .map((file) async => await putObject(
              file.bytes,
              file.filename,
              cancelToken: cancelToken,
              option: file.option,
            ))
        .toList();
    return await Future.wait(uploads);
  }

  /// get object metadata
  @override
  Future<Response<dynamic>> getObjectMeta(
    String fileKey, {
    CancelToken? cancelToken,
    String? bucketName,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'HEAD', {}, {});
    auth.sign(request, bucket, fileKey);

    return _dio.head(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// copy object
  @override
  Future<Response<dynamic>> copyObject(
    CopyRequestOption option, {
    CancelToken? cancelToken,
  }) async {
    final String sourceBucketName = option.sourceBucketName ?? bucketName;
    final String sourceFileKey = option.sourceFileKey;
    final String copySource = "/$sourceBucketName/$sourceFileKey";

    final String targetBucketName = option.targetBucketName ?? sourceBucketName;
    final String targetFileKey = option.targetFileKey ?? sourceFileKey;

    final Map<String, dynamic> internalHeaders = {
      'content-type':
          lookupMimeType(targetFileKey) ?? "application/octet-stream",
      'x-oss-copy-source': copySource,
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-object-acl': option.acl,
      'x-oss-storage-class': option.storage,
    };

    final Map<String, dynamic> externalHeaders = option.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      ...externalHeaders
    };

    final Auth auth = await _getAuth();

    final String url = "https://$targetBucketName.$endpoint/$targetFileKey";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, targetBucketName, targetFileKey);

    return _dio.put(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// get all supported regions
  @override
  Future<Response<dynamic>> getAllRegions({
    CancelToken? cancelToken,
  }) async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint/?regions";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// get bucket acl
  @override
  Future<Response<dynamic>> getBucketAcl({
    String? bucketName,
    CancelToken? cancelToken,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?acl";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?acl");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// get bucket policy
  @override
  Future<Response<dynamic>> getBucketPolicy({
    String? bucketName,
    CancelToken? cancelToken,
  }) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/?policy";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, "?policy");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// delete bucket policy
  @override
  Future<Response<dynamic>> deleteBucketPolicy({
    String? bucketName,
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// put bucket policy
  @override
  Future<Response<dynamic>> putBucketPolicy(
    Map<String, dynamic> policy, {
    String? bucketName,
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// put bucket acl
  @override
  Future<Response<dynamic>> putBucketAcl(
    AclMode aciMode, {
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// get all supported regions
  @override
  Future<Response<dynamic>> getRegion(
    String region, {
    CancelToken? cancelToken,
  }) async {
    final Auth auth = await _getAuth();

    final String url = "https://$endpoint/?regions=$region";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, "", "");

    return _dio.get(
      request.url,
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// delete object from oss
  @override
  Future<Response<dynamic>> deleteObject(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
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
      cancelToken: cancelToken,
      options: Options(headers: request.headers),
    );
  }

  /// delete objects from oss
  @override
  Future<List<Response<dynamic>>> deleteObjects(
    List<String> keys, {
    String? bucketName,
    CancelToken? cancelToken,
  }) async {
    final deletes = keys
        .map((fileKey) async => await deleteObject(
              fileKey,
              bucketName: bucketName,
              cancelToken: cancelToken,
            ))
        .toList();

    return await Future.wait(deletes);
  }

  /// get auth information from sts server
  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      _auth = await authGetter();
      return _auth!;
    }
    return _auth!;
  }

  /// whether auth is valid or not
  bool _isNotAuthenticated() {
    return _auth == null ||
        DateTime.now().isAfter(DateTime.parse(_auth!.expire));
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
