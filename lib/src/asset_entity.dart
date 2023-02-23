import 'package:flutter_oss_aliyun/src/request_option.dart';

class AssetEntity {
  final List<int> bytes;
  final String filename;
  final PutRequestOption? option;

  const AssetEntity({
    required this.filename,
    required this.bytes,
    this.option,
  });
}

class AssetFileEntity {
  final String filepath;
  final String? filename;
  final PutRequestOption? option;

  const AssetFileEntity({
    required this.filepath,
    this.filename,
    this.option,
  });
}
