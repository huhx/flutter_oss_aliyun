import 'package:flutter_oss_aliyun/src/client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

void main() {
  test("test the put object in Client", () async {
    Client.init(
      stsUrl: "server url",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "***",
    );

    final resp = await Client().putObject("Hello World".codeUnits, "test.txt");

    expect(200, resp.statusCode);
  });

  test("test the get object in Client", () async {
    Client.init(
      stsUrl: "server url",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "***",
    );

    final resp = await Client().getObject("test.txt");

    expect(200, resp.statusCode);
  });

  test("test the download object in Client", () async {
    Client.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final resp = await Client().downloadObject("test.txt", "result.txt");

    expect(200, resp.statusCode);
  });
}