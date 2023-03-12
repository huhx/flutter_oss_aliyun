// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Client.init(
      stsUrl: "server sts url",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "bucket name",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter aliyun oss example"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final bytes = "Hello World".codeUnits;
                await Client().putObject(
                  bytes,
                  "filename.txt",
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
                    override: false,
                    aclModel: AclMode.private,
                    storageType: StorageType.standard,
                    callback: Callback(
                      callbackUrl: "callbackUrl",
                      callbackBody:
                          "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
                      callbackVar: {"x:phone": "android"},
                      calbackBodyType: CalbackBodyType.json,
                    ),
                  ),
                );
              },
              child: const Text("Upload object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().getObject(
                  "filename.txt",
                  onReceiveProgress: (count, total) {
                    debugPrint("received = $count, total = $total");
                  },
                );
              },
              child: const Text("Get object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().downloadObject(
                  "filename.txt",
                  "./example/savePath.txt",
                  onReceiveProgress: (count, total) {
                    debugPrint("received = $count, total = $total");
                  },
                );
              },
              child: const Text("Download object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().deleteObject("filename.txt");
              },
              child: const Text("Delete object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().putObjects(
                  [
                    AssetEntity(
                      filename: "filename1.txt",
                      bytes: "files1".codeUnits,
                      option: PutRequestOption(
                        onSendProgress: (count, total) {
                          if (kDebugMode) {
                            print("send: count = $count, and total = $total");
                          }
                        },
                        onReceiveProgress: (count, total) {
                          if (kDebugMode) {
                            print(
                                "receive: count = $count, and total = $total");
                          }
                        },
                        override: true,
                        aclModel: AclMode.inherited,
                      ),
                    ),
                    AssetEntity(
                        filename: "filename2.txt", bytes: "files2".codeUnits),
                  ],
                );
              },
              child: const Text("Batch upload object"),
            ),
            TextButton(
              onPressed: () async {
                await Client()
                    .deleteObjects(["filename1.txt", "filename2.txt"]);
              },
              child: const Text("Batch delete object"),
            ),
          ],
        ),
      ),
    );
  }
}
