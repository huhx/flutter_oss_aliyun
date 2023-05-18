Language: [中文简体](README.md) | [English](README_EN.md)

# flutter_oss_aliyun

一个访问阿里云oss并且支持STS临时访问凭证访问OSS的flutter库，基本上涵盖阿里云oss sdk的所有功能。⭐

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## 🐱&nbsp; 初始化Client

添加依赖

```yaml
dependencies:
  flutter_oss_aliyun: ^6.2.3
```

### **初始化oss client, 这里我们提供两种方式**

#### 1. 提供sts server地址，需要后端添加这个api

```dart
Client.init(
    stsUrl: "server url get sts token",
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucket name",
);
```

后端api至少需要返回以下数据:

```json
{
  "AccessKeyId": "AccessKeyId",
  "AccessKeySecret": "AccessKeySecret",
  "SecurityToken": "SecurityToken",
  "Expiration": "2022-03-22T11:33:06Z"
}
```

#### 2. 自定义authGetter得到Auth

```dart
Client.init(
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucketName",
    authGetter: _authGetter
);

Auth _authGetter() {
  return Auth(
      accessKey: "accessKey",
      accessSecret: 'accessSecret',
      expire: '2023-02-23T14:02:46Z',
      secureToken: 'token',
  );
}
```

**你可以传入`自定义的Dio`**

在init函数中，你可以传入dio，做到dio的定制化。比如日志或者其他的interceptors.

```dart
Client.init(
    stsUrl: "server url get sts token",
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucket name",
    dio: Dio(BaseOptions(connectTimeout: 9000)),
);
```

## 🎨&nbsp;使用

- [文件上传](#put-object)
- [追加文件上传](#append-object)
- [跨bucket文件复制](#copy-object)
- [取消文件上传](#cancel-put-object)
- [批量文件上传](#batch-put-object)
- [本地文件上传](#put-local-object)
- [批量本地文件上传](#batch-put-local-object)
- [文件下载](#download-object)
- [文件下载并保存](#save-object)
- [文件删除](#delete-object)
- [批量文件删除](#batch-delete-object)
- [获取已签名的文件url](#get-signed-url)
- [获取多个已签名的文件url](#batch-get-signed-url)
- [列举所有的存储空间](#list-bucket)
- [列举存储空间中所有文件](#list-file)
- [获取bucket信息](#get-bucket-info)
- [获取bucket的储容量以及文件数量](#get-bucket-detail)
- [获取文件元信息](#get-object-metadata)
- [regions的查询](#regions-query)
- [bucket acl的操作](#bucket-acl)
- [bucket policy的操作](#bucket-policy)

### <span id="put-object">**文件上传**</span>

关于callback的使用: <https://help.aliyun.com/document_detail/31989.htm?spm=a2c4g.11186623.0.0.73a830ffn45LMY#reference-zkm-311-hgb>

```dart
final bytes = "file bytes".codeUnits;

await Client().putObject(
  bytes,
  "test.txt",
  option: PutRequestOption(
    onSendProgress: (count, total) {
      print("send: count = $count, and total = $total");
    },
    onReceiveProgress: (count, total) {
      print("receive: count = $count, and total = $total");
    },
    override: false,
    aclModel: AclMode.publicRead,
    storageType: StorageType.ia,
    headers: {"cache-control": "no-cache"},
    callback: Callback(
      callbackUrl: "callback url",
      callbackBody: "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
      callbackVar: {"x:phone": "android"},
      calbackBodyType: CalbackBodyType.json,
    ),       
  ),
);
```

**PutRequestOption 字段说明,字段皆为非必需**

| Filed       | Default value | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ----------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| override    | true          | true: 允许覆盖同名Object<br>false: 禁止覆盖同名Object                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| aclModel    | inherited     | 1. publicWrite: 任何人（包括匿名访问者）都可以对该Object进行读写操作<br>2. publicRead: 只有该Object的拥有者可以对该Object进行写操作，任何人（包括匿名访问者）都可以对该Object进行读操作<br>3. private: 只有Object的拥有者可以对该Object进行读写操作，其他人无法访问该Object<br>4. inherited: 该Object遵循Bucket的读写权限，即Bucket是什么权限，Object就是什么权限<br>参考文档: <https://help.aliyun.com/document_detail/100676.htm?spm=a2c4g.11186623.0.0.56637952SnxOWV#concept-blw-yqm-2gb> |
| storageType | Standard      | 参考文档: <https://help.aliyun.com/document_detail/51374.htm?spm=a2c4g.11186623.0.0.56632b55htpEQX#concept-fcn-3xt-tdb>                                                                                                                                                                                                                                                                                                                                                                       |

### <span id="append-object">**追加文件上传**</span>

```dart
final Response<dynamic> resp = await Client().appendObject(
  Uint8List.fromList(utf8.encode("Hello World")),
  "test_append.txt",
);

final Response<dynamic> resp2 = await Client().appendObject(
  position: int.parse(resp.headers["x-oss-next-append-position"]?[0]),
  Uint8List.fromList(utf8.encode(", Fluter.")),
  "test_append.txt",
);
```

### <span id="copy-object">**跨bucket复制文件**</span>

```dart
final Response<dynamic> resp = await Client().copyObject(
  const CopyRequestOption(
    sourceFileKey: 'test.csv',
    targetFileKey: "test_copy.csv",
    targetBucketName: "bucket_2"
  ),
);
```

### <span id="cancel-put-object">**取消文件上传**</span>

```dart
final CancelToken cancelToken = CancelToken();
final bytes = ("long long bytes" * 1000).codeUnits;

Client().putObject(
  Uint8List.fromList(utf8.encode(string)),
  "cancel_token_test.txt",
  cancelToken: cancelToken,
  option: PutRequestOption(
    onSendProgress: (count, total) {
      if (kDebugMode) {
        print("send: count = $count, and total = $total");
      }
      if (count > 56) {
        cancelToken.cancel("cancel the uploading.");
      }
    },
  ),
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
```

### <span id="batch-put-object">**批量文件上传**</span>

```dart
await Client().putObjects([
  AssetEntity(
    filename: "filename1.txt",
    bytes: "files1".codeUnits,
    option: PutRequestOption(
      onSendProgress: (count, total) {
        print("send: count = $count, and total = $total");
      },
      onReceiveProgress: (count, total) {
        print("receive: count = $count, and total = $total");
      },
      aclModel: AclMode.private,
    ),
  ),
  AssetEntity(filename: "filename2.txt", bytes: "files2".codeUnits),
]);
```

### <span id="put-local-object">**本地文件上传**</span>

```dart
final Response<dynamic> resp = await Client().putObjectFile(
  "/Users/aaa.pdf",
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
```

### <span id="batch-put-local-object">**批量本地文件上传**</span>

```dart
final List<Response<dynamic>> resp = await Client().putObjectFiles(
  [
    AssetFileEntity(
      filepath: "//Users/private.txt",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
        },
        onReceiveProgress: (count, total) {
          print("receive: count = $count, and total = $total");
        },
        override: false,
        aclModel: AclMode.private,
      ),
    ),
    AssetFileEntity(
      filepath: "//Users/splash.png",
      filename: "aaa.png",
      option: PutRequestOption(
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
        },
        onReceiveProgress: (count, total) {
          print("receive: count = $count, and total = $total");
        },
        override: true,
      ),
    ),
  ],
);
```

### <span id="download-object">**文件下载**</span>

```dart
await Client().getObject(
  "test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### <span id="save-object">**文件下载并保存**</span>

```dart
await Client().downloadObject(
  "test.txt",
  "./example/test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### <span id="delete-object">**文件删除**</span>

```dart
await Client().deleteObject("test.txt");
```

### <span id="batch-delete-object">**批量文件删除**</span>

```dart
await Client().deleteObjects(["filename1.txt", "filename2.txt"]);
```

### <span id="get-signed-url">**获取已签名的文件url**</span>

需要注意的是: 这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短. 这个url可以直接在浏览器访问

```dart
final String url = await Client().getSignedUrl("filename1.txt");
```

### <span id="batch-get-signed-url">**获取多个已签名的文件url**</span>

需要注意的是: 这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短

```dart
final Map<String, String> result = await Client().getSignedUrls(["test.txt", "filename1.txt"]);
```

### <span id="list-bucket">**列举所有的存储空间**</span>

列举请求者拥有的所有存储空间（Bucket）。您还可以通过设置prefix、marker或者max-keys参数列举满足指定条件的存储空间。参考: <https://help.aliyun.com/document_detail/31957.html>

```dart
final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});
```

### <span id="list-file">**列举存储空间中所有文件**</span>

接口用于列举存储空间（Bucket）中所有文件（Object）的信息。请求参数和返回结果，请参考: <https://help.aliyun.com/document_detail/187544.html>

```dart
final Response<dynamic> resp = await Client().listFiles({});
```

### <span id="get-bucket-info">**获取bucket信息**</span>

查看存储空间（Bucket）的相关信息。返回结果请参考: <https://help.aliyun.com/document_detail/31968.html>

```dart
final Response<dynamic> resp = await Client().getBucketInfo();
```

### <span id="get-bucket-detail">**获取bucket的储容量以及文件数量**</span>

获取指定存储空间（Bucket）的存储容量以及文件（Object）数量。返回结果请参考: <https://help.aliyun.com/document_detail/426056.html>

```dart
final Response<dynamic> resp = await Client().getBucketStat();
```

### <span id="get-object-metadata">**获取文件元信息**</span>

```dart
final Response<dynamic> resp = await Client().getObjectMeta("huhx.csv");
```

### <span id="regions-query">**regions的查询**</span>

- 查询所有

```dart
final Response<dynamic> resp = await Client().getAllRegions();
```

- 查询特定

```dart
final Response<dynamic> resp = await Client().getRegion("oss-ap-northeast-1");
```

### <span id="bucket-acl">**bucket acl的操作**</span>

- 查询

```dart
final Response<dynamic> resp = await Client().getBucketAcl(
  bucketName: "bucket-name",
);
```

- 更新

```dart
final Response<dynamic> resp = await Client().putBucketAcl(
  AciMode.publicRead, 
  bucketName: "bucket-name",
);
```

### <span id="bucket-policy">**bucket policy的操作**</span>

- 查询

```dart
final Response<dynamic> resp = await Client().getBucketPolicy(
  bucketName: "bucket-name",
);
```

- 更新

```dart
final Response<dynamic> resp = await Client().putBucketPolicy(
  {}, 
  bucketName: "bucket-name",
);
```

- 删除

```dart
final Response<dynamic> resp = await Client().deleteBucketPolicy(
  bucketName: "bucket-name",
);
```

## Drop a ⭐ if it is help to you
