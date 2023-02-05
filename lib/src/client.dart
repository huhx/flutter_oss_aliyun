import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/multipart/complete_upload_info.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:flutter_oss_aliyun/src/request_option.dart';
import 'package:mime/mime.dart';
import 'package:xml/xml.dart';

import 'asset_entity.dart';
import 'auth.dart';
import 'dio_client.dart';
import 'enums.dart';
import 'multipart/multipart_upload_info.dart';
import 'multipart/part_info.dart';
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

  /// put multi part
  Future<Response<dynamic>> putMultipart(
    File file, {
    String? fileKey,
    int? chunkSize,
    required String taskId,
    CancelToken? cancelToken,
    PutRequestOption? option,
  }) async {
    final MultipartUploadInfo uploadInfo = await initiateMultipartUpload(
      file,
      fileKey: fileKey,
      cancelToken: cancelToken,
      option: option,
    );
    final PartInfo partInfo = PartInfo.from(uploadInfo, chunkSize);

    Future uploadPart(Part part) async {
      final Auth auth = await _getAuth();
      final File file = partInfo.file;
      final Stream<List<int>> stream = file.openRead(part.start, part.end);

      final Map<String, dynamic> internalHeaders = {
        'content-type': "application/octet-stream",
        'content-length': part.end - part.start,
      };

      final Map<String, dynamic> externalHeaders = option?.headers ?? {};
      final Map<String, dynamic> headers = {
        ...internalHeaders,
        ...externalHeaders
      };

      final String params =
          'partNumber=${part.index}&uploadId=${partInfo.uploadId}';
      final String url =
          "https://${partInfo.bucket}.$endpoint/${partInfo.fileKey}?$params";
      final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
      auth.sign(request, partInfo.bucket, "${partInfo.fileKey}?$params");

      final Response<dynamic> response = await _dio.put(
        request.url,
        data: stream,
        options: Options(headers: request.headers),
        cancelToken: cancelToken,
        onSendProgress: option?.onSendProgress,
        onReceiveProgress: option?.onReceiveProgress,
      );
      part.tag = response.headers["etag"]!.first.toString();
      partInfo.progress = part.end;
    }

    final Iterator<Part> iterator =
        partInfo.parts.where((item) => item.tag == null).iterator;
    while (iterator.moveNext()) {
      await uploadPart(iterator.current);
    }

    if (partInfo.isCompleted) {
      return completeMultipartUpload(
        partInfo,
        cancelToken: cancelToken,
        option: option,
      );
    }
    return Future.error("Failed uploaded $taskId");
  }

  /// InitiateMultipartUpload
  Future<MultipartUploadInfo> initiateMultipartUpload(
    File file, {
    String? fileKey,
    CancelToken? cancelToken,
    PutRequestOption? option,
  }) async {
    final String bucket = option?.bucketName ?? bucketName;
    final String filename =
        fileKey ?? file.path.split(Platform.pathSeparator).last;
    final Auth auth = await _getAuth();

    final Map<String, dynamic> internalHeaders = {
      'content-type': lookupMimeType(filename) ?? "application/octet-stream",
      'x-oss-forbid-overwrite': option.forbidOverride,
      'x-oss-storage-class': option.storage,
    };

    final Map<String, dynamic> externalHeaders = option?.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      ...externalHeaders
    };

    final String url = "https://$bucket.$endpoint/$filename?uploads";
    final HttpRequest request = HttpRequest(url, 'POST', {}, headers);
    auth.sign(request, bucket, "$filename?uploads");

    final Response<dynamic> response = await _dio.post(
      request.url,
      options: Options(headers: request.headers),
      cancelToken: cancelToken,
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );

    final XmlDocument document = XmlDocument.parse(response.data);
    final XmlElement uploadIdElement =
        document.findAllElements("UploadId").first;
    final int length = await file.length();
    return MultipartUploadInfo(
      fileKey: filename,
      length: length,
      bucket: bucket,
      uploadId: uploadIdElement.text,
      file: file,
    );
  }

  /// completeMultipartUpload
  Future<Response<dynamic>> completeMultipartUpload(
    PartInfo partInfo, {
    CancelToken? cancelToken,
    PutRequestOption? option,
  }) async {
    final String bucket = partInfo.bucket;
    final String filename = partInfo.fileKey;
    final String uploadId = partInfo.uploadId;

    final Auth auth = await _getAuth();

    final CompleteMultipartUpload multipartUpload =
        CompleteMultipartUpload.from(partInfo.parts);
    final String xmlString = multipartUpload.toXml();

    final Map<String, dynamic> internalHeaders = {
      'content-type': 'application/xml',
      'content-length': xmlString.length,
    };

    final Map<String, dynamic> externalHeaders = option?.headers ?? {};
    final Map<String, dynamic> headers = {
      ...internalHeaders,
      ...externalHeaders
    };

    final String url = "https://$bucket.$endpoint/$filename?uploadId=$uploadId";
    final HttpRequest request = HttpRequest(url, 'POST', {}, headers);
    auth.sign(request, bucket, "$filename?uploadId=$uploadId");

    return await _dio.post(
      request.url,
      data: xmlString,
      options: Options(headers: request.headers),
      cancelToken: cancelToken,
      onSendProgress: option?.onSendProgress,
      onReceiveProgress: option?.onReceiveProgress,
    );
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
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
      ...externalHeaders
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
  /// [file] is the file that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObjectFile(
    File file, {
    PutRequestOption? option,
    CancelToken? cancelToken,
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
  Future<List<Response<dynamic>>> putObjectFiles(
    List<AssetFileEntity> assetEntities, {
    CancelToken? cancelToken,
  }) async {
    final uploads = assetEntities
        .map((fileEntity) async => await putObjectFile(
              fileEntity.file,
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
