import 'package:dio/dio.dart';

class PutRequestOption {
  final String? bucketName;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final bool? isOverwrite;

  const PutRequestOption({
    this.bucketName,
    this.onSendProgress,
    this.onReceiveProgress,
    this.isOverwrite,
  });
}
