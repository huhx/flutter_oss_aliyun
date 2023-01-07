Language: [中文简体](README.md) | [English](README_EN.md)

# flutter_oss_aliyun

一个访问阿里云oss并且支持STS临时访问凭证访问OSS的flutter库，基本上涵盖阿里云oss sdk的所有功能。⭐

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## 🐱&nbsp; 初始化Client
添加依赖
```yaml
dependencies:
  flutter_oss_aliyun: ^5.1.3
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

#### 2. 当然你可以自定义使用其他的方式返回以下的json数据.
```dart
Client.init(
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucketName",
    tokenGetter: _tokenGetterMethod
);

String _tokenGetterMethod() async {
  return '''{
        "AccessKeyId": "access id",
        "AccessKeySecret": "AccessKeySecret",
        "SecurityToken": "security token",
        "Expiration": "2022-03-22T11:33:06Z"
    }''';
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
- [上传文件附带进度回调](#put-object)
- [批量上传文件](#batch-put-object)
- [上传本地文件](#put-local-object)
- [批量上传本地文件](#batch-put-local-object)
- [下载文件附带进度回调](#download-object)
- [下载并保存文件附带进度回调](#save-object)
- [删除文件](#delete-object)
- [批量删除文件](#batch-delete-object)
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

### <span id="put-object">**上传文件附带进度回调**</span>
* 存储类型：https://help.aliyun.com/document_detail/51374.htm?spm=a2c4g.11186623.0.0.56632b55htpEQX#concept-fcn-3xt-tdb
* acl策略：https://help.aliyun.com/document_detail/100676.htm?spm=a2c4g.11186623.0.0.56637952SnxOWV#concept-blw-yqm-2gb

**PutRequestOption 字段说明,字段皆为非必需**

| Filed       | Default value | Description                                                                                                                                                                                                                                                                                                                                                       |
| ----------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| override    | true          | true: 允许覆盖同名Object<br>false: 禁止覆盖同名Object                                                                                                                                                                                                                                                                                                             |
| aclModel    | inherited     | 1. publicWrite: 任何人（包括匿名访问者）都可以对该Object进行读写操作<br>2. publicRead: 只有该Object的拥有者可以对该Object进行写操作，任何人（包括匿名访问者）都可以对该Object进行读操作<br>3. private: 只有Object的拥有者可以对该Object进行读写操作，其他人无法访问该Object<br>4. inherited: 该Object遵循Bucket的读写权限，即Bucket是什么权限，Object就是什么权限 |
| storageType | Standard      | 参考：https://help.aliyun.com/document_detail/51374.htm?spm=a2c4g.11186623.0.0.56632b55htpEQX#concept-fcn-3xt-tdb                                                                                                                                                                                                                                                 |

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
  ),
);
```

### <span id="batch-put-object">**批量上传文件**</span>
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


### <span id="put-local-object">**上传本地文件**</span>

```dart
final Response<dynamic> resp = await Client().putObjectFile(
  File("/Users/aaa.pdf"),
  fileKey: "aaa.png",
  option: PutRequestOption(
    onSendProgress: (count, total) {
      print("send: count = $count, and total = $total");
    },
    onReceiveProgress: (count, total) {
      print("receive: count = $count, and total = $total");
    },
    aclModel: AclMode.private,
  ),
);
```

### <span id="batch-put-local-object">**批量上传本地文件**</span>

```dart
final List<Response<dynamic>> resp = await Client().putObjectFiles(
  [
    AssetFileEntity(
      file: File("//Users/private.txt"),
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
      file: File("//Users/splash.png"),
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

### <span id="download-object">**下载文件附带进度回调**</span>
```dart
await Client().getObject(
  "test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### <span id="save-object">**下载并保存文件附带进度回调**</span>
```dart
await Client().downloadObject(
  "test.txt",
  "./example/test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### <span id="delete-object">**删除文件**</span>
```dart
await Client().deleteObject("test.txt");
```

### <span id="batch-delete-object">**批量删除文件**</span>
```dart
await Client().deleteObjects(["filename1.txt", "filename2.txt"]);
```

### <span id="get-signed-url">**获取已签名的文件url**</span>
需要注意的是：这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短. 这个url可以直接在浏览器访问

```dart
final String url = await Client().getSignedUrl("filename1.txt");
```

### <span id="batch-get-signed-url">**获取多个已签名的文件url**</span>
需要注意的是：这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短

```dart
final Map<String, String> result = await Client().getSignedUrls(["test.txt", "filename1.txt"]);
```

### <span id="list-bucket">**列举所有的存储空间**</span>
列举请求者拥有的所有存储空间（Bucket）。您还可以通过设置prefix、marker或者max-keys参数列举满足指定条件的存储空间。参考：https://help.aliyun.com/document_detail/31957.html

```dart
final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});
```

### <span id="list-file">**列举存储空间中所有文件**</span>
接口用于列举存储空间（Bucket）中所有文件（Object）的信息。请求参数和返回结果，请参考: https://help.aliyun.com/document_detail/187544.html

```dart
final Response<dynamic> resp = await Client().listFiles({});
```

### <span id="get-bucket-info">**获取bucket信息**</span>
查看存储空间（Bucket）的相关信息。返回结果请参考: https://help.aliyun.com/document_detail/31968.html

```dart
final Response<dynamic> resp = await Client().getBucketInfo();
```

### <span id="get-bucket-detail">**获取bucket的储容量以及文件数量**</span>
获取指定存储空间（Bucket）的存储容量以及文件（Object）数量。返回结果请参考: https://help.aliyun.com/document_detail/426056.html

```dart
final Response<dynamic> resp = await Client().getBucketStat();
```

### <span id="get-object-metadata">**获取文件元信息**</span>

```dart
final Response<dynamic> resp = await Client().getObjectMeta("huhx.csv");
```

### <span id="regions-query">**regions的查询**</span>
* 查询所有

```dart
final Response<dynamic> resp = await Client().getAllRegions();
```

* 查询特定

```dart
final Response<dynamic> resp = await Client().getRegion("oss-ap-northeast-1");
```

### <span id="bucket-acl">**bucket acl的操作**</span>
* 查询

```dart
final Response<dynamic> resp = await Client().getBucketAcl(
  bucketName: "bucket-name",
);
```

* 更新

```dart
final Response<dynamic> resp = await Client().putBucketAcl(
  AciMode.publicRead, 
  bucketName: "bucket-name",
);
```

### <span id="bucket-policy">**bucket policy的操作**</span>
* 查询

```dart
final Response<dynamic> resp = await Client().getBucketPolicy(
  bucketName: "bucket-name",
);
```

* 更新

```dart
final Response<dynamic> resp = await Client().putBucketPolicy(
  {}, 
  bucketName: "bucket-name",
);
```

* 删除
```dart
final Response<dynamic> resp = await Client().deleteBucketPolicy(
  bucketName: "bucket-name",
);
```

## Drop a ⭐ if it is help to you.
