import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String home;
  late String callbackUrl;

  setUpAll(() {
    final Map<String, String> env = Platform.environment;
    home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    callbackUrl = env['oss_callback_url'] ?? "";

    Client.init(
      stsUrl: env["sts_url"],
      ossEndpoint: env["oss_endpoint"] ?? "",
      bucketName: env["bucket_name"] ?? "",
    );
  });

  test("test the put object in Client", () async {
    final File file = File("$home/Downloads/idiom.csv");
    final String string = await file.readAsString();

    final Response<dynamic> resp = await Client().putObject(
      Uint8List.fromList(utf8.encode(string)),
      "test.csv",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
        },
        onReceiveProgress: (count, total) {
          print("receive: count = $count, and total = $total");
        },
        override: true,
        aclModel: AclMode.publicRead,
        storageType: StorageType.ia,
        headers: {"content-type": "text/csv"},
        callback: Callback(
          callbackUrl: callbackUrl,
          callbackBody:
              "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
          callbackVar: {"x:phone": "android"},
          calbackBodyType: CalbackBodyType.json,
        ),
      ),
    );

    expect(resp.statusCode, 200);
  });

  test("test the copy object in Client", () async {
    final Response<dynamic> resp = await Client().copyObject(
      const CopyRequestOption(
        sourceFileKey: 'test.csv',
        targetFileKey: "test_copy.csv",
      ),
    );

    expect(resp.statusCode, 200);
  });

  test("test the append object in Client", () async {
    final Response<dynamic> resp = await Client().appendObject(
      Uint8List.fromList(utf8.encode("Hello World")),
      "test_append.txt",
    );

    expect(resp.statusCode, 200);
    expect(resp.headers["x-oss-next-append-position"]?[0], "11");

    final Response<dynamic> resp2 = await Client().appendObject(
      position: 11,
      Uint8List.fromList(utf8.encode(", Fluter.")),
      "test_append.txt",
    );

    expect(resp2.statusCode, 200);
    expect(resp2.headers["x-oss-next-append-position"]?[0], "20");

    await Client().deleteObject("test_append.txt");
  });

  test("test the put object cancel token in Client", () async {
    final CancelToken cancelToken = CancelToken();

    final File file = File("$home/Downloads/idiom.csv");
    final String string = file.readAsStringSync();

    await Client().putObject(
      Uint8List.fromList(utf8.encode(string)),
      "cancel_token_test2.csv",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
          if (count > 56) {
            cancelToken.cancel("cancel the uploading.");
          }
        },
      ),
      cancelToken: cancelToken,
    ).then((response) {
      // success
      print("upload success = ${response.statusCode}");
    }).catchError((err) {
      if (CancelToken.isCancel(err)) {
        print("error message = ${err.message}");
      } else {
        // handle other errors
      }
    });
  });

  test("test the get object metadata in Client", () async {
    final Response<dynamic> resp = await Client().getObjectMeta("test.csv");

    expect(resp.statusCode, 200);
  });

  test("test the get all regions in Client", () async {
    final Response<dynamic> resp = await Client().getAllRegions();

    expect(resp.statusCode, 200);
  });

  test("test the get regions in Client", () async {
    final Response<dynamic> resp =
        await Client().getRegion("oss-ap-northeast-1");

    expect(resp.statusCode, 200);
  });

  test("test the put bucket acl in Client", () async {
    final Response<dynamic> resp = await Client().putBucketAcl(
      AclMode.publicRead,
      bucketName: "huhx-family-dev",
    );

    expect(resp.statusCode, 200);
  });

  test("test the get bucket acl in Client", () async {
    final Response<dynamic> resp = await Client().getBucketAcl(
      bucketName: "huhx-family-dev",
    );

    expect(resp.statusCode, 200);
  });

  test("test the get bucket policy in Client", () async {
    final Response<dynamic> resp = await Client().getBucketPolicy(
      bucketName: "huhx-family-dev",
    );

    expect(resp.statusCode, 200);
  });

  test("test the delete bucket policy in Client", () async {
    final Response<dynamic> resp = await Client().deleteBucketPolicy(
      bucketName: "huhx-family-dev",
    );

    expect(resp.statusCode, 204);
  });

  test("test the put bucket policy in Client", () async {
    const Map<String, dynamic> policy = {
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

    expect(resp.statusCode, 200);
  });

  test("test the put object file in Client", () async {
    final Response<dynamic> resp = await Client().putObjectFile(
      "$home/Downloads/journal_bg-min.png",
      fileKey: "aaa.png",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
        },
        onReceiveProgress: (count, total) {
          print("receive: count = $count, and total = $total");
        },
        aclModel: AclMode.private,
        callback: Callback(
          callbackUrl: callbackUrl,
          callbackBody:
              "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
          callbackVar: {"x:phone": "android"},
          calbackBodyType: CalbackBodyType.json,
        ),
      ),
    );

    expect(resp.statusCode, 200);
  });

  test("test the put object files in Client", () async {
    final List<Response<dynamic>> resp = await Client().putObjectFiles([
      AssetFileEntity(
        filepath: "$home/Downloads/test.txt",
        option: PutRequestOption(
          onSendProgress: (count, total) {
            print("1: send: count = $count, and total = $total");
          },
        ),
      ),
      AssetFileEntity(
        filepath: "$home/Downloads/splash.png",
        filename: "aaa.png",
        option: PutRequestOption(
          onSendProgress: (count, total) {
            print("2: send: count = $count, and total = $total");
          },
        ),
      ),
    ]);

    expect(resp.length, 2);
  });

  test("test the list objects in Client", () async {
    final Response<dynamic> resp = await Client().listObjects({
      "max-keys": 12,
      "continuation-token": "ChgyMDIxMTIyMDExMzYyMTAzNDIxNS5qcGcQAA--",
      "prefix": "aaa"
    });

    print(resp);
    expect(resp.statusCode, 200);
  });

  test("test the list buckets in Client", () async {
    final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});

    print(resp);
    expect(resp.statusCode, 200);
  });

  test("test the get bucket info in Client", () async {
    final Response<dynamic> resp = await Client().getBucketInfo();

    print(resp);
    expect(resp.statusCode, 200);
  });

  test("test the get bucket info in Client", () async {
    final Response<dynamic> resp = await Client().getBucketStat();

    print(resp);

    expect(resp.statusCode, 200);
  });

  test("test the get object in Client", () async {
    final Response<dynamic> resp = await Client().getObject("test.txt");

    expect(resp.statusCode, 200);
  });

  test("test the download object in Client", () async {
    final Response resp = await Client().downloadObject(
      "test.txt",
      "result.txt",
    );
    final File file = File("result.txt");

    expect(resp.statusCode, 200);
    expect(file.existsSync(), true);

    // tear down: delete result.txt
    file.delete();
  });

  test("test the delete object in Client", () async {
    final Response<dynamic> resp = await Client().deleteObject("test.txt");

    expect(resp.statusCode, 204);
  });

  test("test the put objects in Client", () async {
    final List<Response<dynamic>> resp = await Client().putObjects([
      AssetEntity(filename: "filename1.txt", bytes: "files1".codeUnits),
      AssetEntity(filename: "filename2.txt", bytes: "files2".codeUnits),
    ]);

    expect(resp.length, 2);
    expect(resp[0].statusCode, 200);
    expect(resp[1].statusCode, 200);
  });

  test("test the delete objects in Client", () async {
    final List<Response<dynamic>> resp = await Client().deleteObjects([
      "filename1.txt",
      "filename2.txt",
    ]);

    expect(resp.length, 2);
    expect(resp[0].statusCode, 204);
    expect(resp[1].statusCode, 204);
  });

  test("test the get object url in Client", () async {
    final String url = await Client().getSignedUrl("test.csv");
    print("download url = $url");

    expect(url, isNotNull);
  });

  test("test the get object urls in Client", () async {
    final Map<String, String> result = await Client().getSignedUrls([
      "20220106121416393842.jpg",
      "20220106095156755058.jpg",
    ]);

    print(result);

    expect(result.length, 2);
  });
}
