import 'package:dio/dio.dart';

import 'callback.dart';
import 'enums.dart';

class PutRequestOption {
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

  final String? bucketName;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final AclMode? aclModel;
  final bool? override;
  final StorageType? storageType;
  final Map<String, dynamic>? headers;
  final Callback? callback;
}

class CopyRequestOption {
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
}
