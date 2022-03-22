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
                await Client().putObject(bytes, "filename.txt");
              },
              child: const Text("Upload object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().downloadObject("filename.txt", "savePath.txt");
              },
              child: const Text("Download object"),
            ),
            TextButton(
              onPressed: () async {
                await Client().deleteObject("filename.txt");
              },
              child: const Text("Delete object"),
            ),
          ],
        ),
      ),
    );
  }
}
