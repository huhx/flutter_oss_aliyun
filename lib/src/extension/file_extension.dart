import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dio/dio.dart';

extension MultipartFileExtension on MultipartFile {
  /// chunk multipartFile to stream, chunk size is: 64KB
  Stream<List<int>> chunk() async* {
    final reader = ChunkedStreamReader<int>(finalize());
    while (true) {
      final Uint8List data = await reader.readBytes(64 * 1024);
      if (data.isEmpty) {
        break;
      }
      yield data;
    }
  }
}
