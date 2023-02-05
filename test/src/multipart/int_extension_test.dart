import 'package:flutter_oss_aliyun/src/multipart/int_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test chunk method', () {
    final int size = 10.chunk(3);

    expect(size, 4);
  });
}
