import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:flutter_oss_aliyun/src/callback.dart';

class PutRequestOption {
  final String? bucketName;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final AclMode? aclModel;
  final bool? override;
  final StorageType? storageType;
  final Map<String, dynamic>? headers;
  final Callback? callback;

  const PutRequestOption({
    this.bucketName,
    this.onSendProgress,
    this.onReceiveProgress,
    this.aclModel,
    this.override,
    this.storageType,
    this.headers,
    this.callback,
  });
}

class CopyRequestOption {
  final String? sourceBucketName;
  final String sourceFileKey;
  final String? targetBucketName;
  final String? targetFileKey;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final AclMode? aclModel;
  final bool? override;
  final StorageType? storageType;
  final Map<String, dynamic>? headers;

  const CopyRequestOption({
    this.sourceBucketName,
    required this.sourceFileKey,
    this.targetBucketName,
    this.targetFileKey,
    this.onSendProgress,
    this.onReceiveProgress,
    this.aclModel,
    this.override,
    this.storageType,
    this.headers,
  });
}
