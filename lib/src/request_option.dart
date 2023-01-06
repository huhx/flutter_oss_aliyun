import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

class PutRequestOption {
  final String? bucketName;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final AclMode? acl;
  final bool? isOverwrite;
  final StorageType? storageType;

  const PutRequestOption({
    this.bucketName,
    this.onSendProgress,
    this.onReceiveProgress,
    this.acl,
    this.isOverwrite,
    this.storageType,
  });
}
