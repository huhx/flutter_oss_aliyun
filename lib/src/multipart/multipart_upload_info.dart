import 'dart:io';

class MultipartUploadInfo {
  final String fileKey;
  final int length;
  final String bucket;
  final String uploadId;
  final File file;

  const MultipartUploadInfo({
    required this.fileKey,
    required this.length,
    required this.bucket,
    required this.uploadId,
    required this.file,
  });
}
