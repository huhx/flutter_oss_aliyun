import 'dart:math';

import 'package:flutter_oss_aliyun/src/multipart/int_extension.dart';

import 'part_info.dart';

class PartUtil {
  static List<Part> splitParts(int length, int chunkSize) {
    final int count = length.chunk(chunkSize);
    return Iterable.generate(count).map((index) {
      final int start = index * chunkSize;
      final int end = min(start + chunkSize, length);

      return Part(index: index + 1, start: index * chunkSize, end: end);
    }).toList();
  }
}
