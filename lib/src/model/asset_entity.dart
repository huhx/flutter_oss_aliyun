import 'request_option.dart';

class AssetEntity {
  const AssetEntity({
    required this.filename,
    required this.bytes,
    this.option,
  });

  final List<int> bytes;
  final String filename;
  final PutRequestOption? option;
}

class AssetFileEntity {
  const AssetFileEntity({
    required this.filepath,
    this.filename,
    this.option,
  });

  final String filepath;
  final String? filename;
  final PutRequestOption? option;
}
