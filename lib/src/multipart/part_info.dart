import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_oss_aliyun/src/multipart/multipart_upload_info.dart';

import 'part_util.dart';

class PartInfo extends Equatable {
  final String fileKey;
  final int length;
  final String bucket;
  final String uploadId;
  final File file;
  final List<Part> parts;

  const PartInfo({
    required this.fileKey,
    required this.length,
    required this.bucket,
    required this.uploadId,
    required this.file,
    required this.parts,
  });

  @override
  List<Object?> get props => [fileKey, length, bucket, uploadId, file, parts];

  factory PartInfo.from(MultipartUploadInfo uploadInfo, int? chunkSize) {
    final List<Part> parts = PartUtil.splitParts(uploadInfo.length, chunkSize ?? 10 * 1000);
    return PartInfo(
      fileKey: uploadInfo.fileKey,
      length: uploadInfo.length,
      bucket: uploadInfo.bucket,
      uploadId: uploadInfo.uploadId,
      file: uploadInfo.file,
      parts: parts,
    );
  }
}

class Part extends Equatable {
  final int index;
  final int start;
  final int end;

  const Part({
    required this.index,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [index, start, end];
}
