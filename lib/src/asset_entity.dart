import 'dart:io';

import 'package:dio/dio.dart';

class AssetEntity {
  final List<int> bytes;
  final String filename;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;

  const AssetEntity({
    required this.filename,
    required this.bytes,
    this.onSendProgress,
    this.onReceiveProgress,
  });
}

class AssetFileEntity {
  final File file;
  final String? filename;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;

  const AssetFileEntity({
    required this.file,
    this.filename,
    this.onSendProgress,
    this.onReceiveProgress,
  });
}
