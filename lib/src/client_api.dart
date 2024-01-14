import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/model/asset_entity.dart';
import 'package:flutter_oss_aliyun/src/model/enums.dart';
import 'package:flutter_oss_aliyun/src/model/request_option.dart';

abstract class ClientApi {
  Future<Response<dynamic>> getObject(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onReceiveProgress,
  });

  Future<bool> doesObjectExist(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
    Options? options,
  });

  Future<String> getSignedUrl(
    String fileKey, {
    String? bucketName,
    int expireSeconds = 60,
  });

  Future<Map<String, String>> getSignedUrls(
    List<String> fileKeys, {
    String? bucketName,
    int expireSeconds = 60,
  });

  Future<Response<dynamic>> listBuckets(
    Map<String, dynamic> parameters, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<dynamic>> listObjects(
    Map<String, dynamic> parameters, {
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<dynamic>> getBucketInfo({
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<dynamic>> getBucketStat({
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response> downloadObject(
    String fileKey,
    String savePath, {
    String? bucketName,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<dynamic>> putObject(
    List<int> fileData,
    String fileKey, {
    CancelToken? cancelToken,
    PutRequestOption? option,
  });

  Future<Response<dynamic>> appendObject(
    List<int> fileData,
    String fileKey, {
    CancelToken? cancelToken,
    PutRequestOption? option,
    int? position,
  });

  Future<List<Response<dynamic>>> putObjects(
    List<AssetEntity> assetEntities, {
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> putObjectFile(
    String filepath, {
    PutRequestOption? option,
    CancelToken? cancelToken,
    String? fileKey,
  });

  Future<List<Response<dynamic>>> putObjectFiles(
    List<AssetFileEntity> assetEntities, {
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> getObjectMeta(
    String fileKey, {
    CancelToken? cancelToken,
    String? bucketName,
  });

  Future<Response<dynamic>> copyObject(
    CopyRequestOption option, {
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> getAllRegions({
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> getBucketAcl({
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> getBucketPolicy({
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> deleteBucketPolicy({
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> putBucketPolicy(
    Map<String, dynamic> policy, {
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> putBucketAcl(
    AclMode aciMode, {
    CancelToken? cancelToken,
    String? bucketName,
  });

  Future<Response<dynamic>> getRegion(
    String region, {
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> deleteObject(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<List<Response<dynamic>>> deleteObjects(
    List<String> keys, {
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> initiateMultipartUpload(
    String fileKey, {
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> uploadPart(
    String fileKey,
    List<int> partData,
    int partNumber,
    String uploadId, {
    String? bucketName,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> completeMultipartUpload(
    String fileKey,
    String uploadId,
    String data, {
    String? bucketName,
    CancelToken? cancelToken,
  });
}
