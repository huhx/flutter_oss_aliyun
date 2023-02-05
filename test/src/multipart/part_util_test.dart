import 'package:flutter_oss_aliyun/src/multipart/part_info.dart';
import 'package:flutter_oss_aliyun/src/multipart/part_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('part util test split parts method', () {
    final List<Part> splitParts = PartUtil.splitParts(10, 3);

    expect(splitParts.length, 4);
    expect(splitParts[0], Part(index: 1, start: 0, end: 3));
    expect(splitParts[1], Part(index: 2, start: 3, end: 6));
    expect(splitParts[2], Part(index: 3, start: 6, end: 9));
    expect(splitParts[3], Part(index: 4, start: 9, end: 10));
  });
}
