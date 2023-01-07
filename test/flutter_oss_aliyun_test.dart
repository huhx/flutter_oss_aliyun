import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String home;

  setUpAll(() {
    final Map<String, String> env = Platform.environment;
    home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;

    Client.init(
      stsUrl: env["sts_url"],
      ossEndpoint: env["oss_endpoint"] ?? "",
      bucketName: env["bucket_name"] ?? "",
    );
  });

  test("test the put object in Client", () async {
    var file = File("$home/Downloads/idiom.csv");
    var string = await file.readAsString();
    final Response<dynamic> resp = await Client().putObject(
      Uint8List.fromList(utf8.encode(string)),
      "test.csv",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          if (kDebugMode) {
            print("send: count = $count, and total = $total");
          }
        },
        onReceiveProgress: (count, total) {
          if (kDebugMode) {
            print("receive: count = $count, and total = $total");
          }
        },
        override: true,
        aclModel: AclMode.publicRead,
        storageType: StorageType.ia,
      ),
    );

    expect(200, resp.statusCode);
  });

  test("test the get object metadata in Client", () async {
    final Response<dynamic> resp = await Client().getObjectMeta("test.csv");

    expect(200, resp.statusCode);
  });

  test("test the get all regions in Client", () async {
    final Response<dynamic> resp = await Client().getAllRegions();

    expect(200, resp.statusCode);
  });

  test("test the get regions in Client", () async {
    final Response<dynamic> resp =
        await Client().getRegion("oss-ap-northeast-1");

    expect(200, resp.statusCode);
  });

  test("test the put bucket acl in Client", () async {
    final Response<dynamic> resp = await Client()
        .putBucketAcl(AclMode.publicRead, bucketName: "huhx-family-dev");

    expect(200, resp.statusCode);
  });

  test("test the get bucket acl in Client", () async {
    final Response<dynamic> resp = await Client().getBucketAcl(
      bucketName: "huhx-family-dev",
    );

    expect(200, resp.statusCode);
  });

  test("test the get bucket policy in Client", () async {
    final Response<dynamic> resp = await Client().getBucketPolicy(
      bucketName: "huhx-family-dev",
    );

    expect(200, resp.statusCode);
  });

  test("test the delete bucket policy in Client", () async {
    final Response<dynamic> resp = await Client().deleteBucketPolicy(
      bucketName: "huhx-family-dev",
    );

    expect(204, resp.statusCode);
  });

  test("test the put bucket policy in Client", () async {
    Map<String, dynamic> policy = {
      "Version": "1",
      "Statement": [
        {
          "Principal": ["221050028580141672"],
          "Effect": "Allow",
          "Resource": [
            "acs:oss:*:1504416580632704:huhx-family-dev",
            "acs:oss:*:1504416580632704:huhx-family-dev/*"
          ],
          "Action": [
            "oss:GetObject",
            "oss:GetObjectAcl",
            "oss:RestoreObject",
            "oss:GetVodPlaylist",
            "oss:GetObjectVersion",
            "oss:GetObjectVersionAcl",
            "oss:RestoreObjectVersion"
          ]
        }
      ]
    };

    final Response<dynamic> resp = await Client().putBucketPolicy(
      policy,
      bucketName: "huhx-family-dev",
    );

    expect(200, resp.statusCode);
  });

  test("test the put object file in Client", () async {
    final Response<dynamic> resp = await Client().putObjectFile(
      File("$home/Downloads/journal_bg-min.png"),
      fileKey: "aaa.png",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          if (kDebugMode) {
            print("send: count = $count, and total = $total");
          }
        },
        onReceiveProgress: (count, total) {
          if (kDebugMode) {
            print("receive: count = $count, and total = $total");
          }
        },
        aclModel: AclMode.private,
      ),
    );

    expect(200, resp.statusCode);
  });

  test("test the put object files in Client", () async {
    final List<Response<dynamic>> resp = await Client().putObjectFiles(
      [
        AssetFileEntity(
          file: File("$home/Downloads/test.txt"),
          option: PutRequestOption(
            onSendProgress: (count, total) {
              if (kDebugMode) {
                print("1: send: count = $count, and total = $total");
              }
            },
          ),
        ),
        AssetFileEntity(
          file: File("$home/Downloads/splash.png"),
          filename: "aaa.png",
          option: PutRequestOption(
            onSendProgress: (count, total) {
              if (kDebugMode) {
                print("2: send: count = $count, and total = $total");
              }
            },
          ),
        ),
      ],
    );

    expect(2, resp.length);
  });

  test("test the list objects in Client", () async {
    final Response<dynamic> resp = await Client().listObjects({"max-keys": 12});

    if (kDebugMode) {
      print(resp);
    }
    expect(200, resp.statusCode);
  });

  test("test the list buckets in Client", () async {
    final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});

    if (kDebugMode) {
      print(resp);
    }
    expect(200, resp.statusCode);
  });

  test("test the get bucket info in Client", () async {
    final Response<dynamic> resp = await Client().getBucketInfo();

    if (kDebugMode) {
      print(resp);
    }
    expect(200, resp.statusCode);
  });

  test("test the get bucket info in Client", () async {
    final Response<dynamic> resp = await Client().getBucketStat();

    if (kDebugMode) {
      print(resp);
    }

    expect(200, resp.statusCode);
  });

  test("test the get object in Client", () async {
    final Response<dynamic> resp = await Client().getObject("test.txt");

    expect(200, resp.statusCode);
  });

  test("test the download object in Client", () async {
    final Response resp =
        await Client().downloadObject("test.txt", "result.txt");

    expect(200, resp.statusCode);
  });

  test("test the delete object in Client", () async {
    final Response<dynamic> resp = await Client().deleteObject("test.txt");

    expect(204, resp.statusCode);
  });

  test("test the put objects in Client", () async {
    final List<Response<dynamic>> resp = await Client().putObjects([
      AssetEntity(filename: "filename1.txt", bytes: "files1".codeUnits),
      AssetEntity(filename: "filename2.txt", bytes: "files2".codeUnits),
    ]);

    expect(2, resp.length);
    expect(200, resp[0].statusCode);
    expect(200, resp[1].statusCode);
  });

  test("test the delete objects in Client", () async {
    final List<Response<dynamic>> resp = await Client().deleteObjects([
      "filename1.txt",
      "filename2.txt",
    ]);

    expect(2, resp.length);
    expect(204, resp[0].statusCode);
    expect(204, resp[1].statusCode);
  });

  test("test the get object url in Client", () async {
    final String url = await Client().getSignedUrl("test.txt");
    if (kDebugMode) {
      print("downloadurl $url");
    }

    expect(url, isNotNull);
  });

  test("test the get object urls in Client", () async {
    final Map<String, String> result = await Client().getSignedUrls([
      "20220106121416393842.jpg",
      "20220106095156755058.jpg",
    ]);

    if (kDebugMode) {
      print(result);
    }

    expect(result.length, 2);
  });
}
