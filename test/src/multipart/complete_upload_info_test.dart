import 'package:flutter_oss_aliyun/src/multipart/complete_upload_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test CompleteMultipartUpload toXml', () async {
    const List<Part> parts = [
      Part(index: 1, eTag: "aaa"),
      Part(index: 2, eTag: "bbb"),
    ];
    const CompleteMultipartUpload multipartUpload =
        CompleteMultipartUpload(parts);

    final String result = multipartUpload.toXml();

    expect(result,
        '''<CompleteMultipartUpload><Part><PartNumber>1</PartNumber><ETag>"aaa"</ETag></Part><Part><PartNumber>2</PartNumber><ETag>"bbb"</ETag></Part></CompleteMultipartUpload>''');
  });
}
