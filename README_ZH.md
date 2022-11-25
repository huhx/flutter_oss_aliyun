Language: [English](README.md) | [中文简体](README_ZH.md)

# flutter_oss_aliyun

一个访问阿里云oss并且支持STS临时访问凭证访问OSS的flutter库

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## 功能
- [x] 上传文件
- [x] 下载文件
- [x] 下载并保存文件
- [x] 删除文件
- [x] 多文件上传
- [x] 多文件删除
- [x] 上传文件的进度回调函数
- [x] 下载文件的进度回调函数
- [x] 获取签名的文件url
- [x] 获取多个签名的文件url
- [x] 列举存储空间中所有文件
- [x] 获取bucket信息
- [x] 获取bucket的储容量以及文件数量


## 使用
添加依赖
```yaml
dependencies:
  flutter_oss_aliyun: ^4.1.1
```

### 1. 初始化oss client, 这里我们提供两种方式
#### 提供sts server地址，需要后端添加这个api
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

#### 当然你可以自定义使用其他的方式返回以下的json数据.
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

### 2. 上传文件附带进度回调
```dart
final bytes = "file bytes".codeUnits;

await Client().putObject(
  bytes,
  "test.txt",
  onSendProgress: (count, total) {
    debugPrint("sent = $count, total = $total");
  },
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  }
);
```

### 3. 下载文件附带进度回调
```dart
await Client().getObject(
  "test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### 4. 下载并保存文件附带进度回调
```dart
await Client().downloadObject(
  "test.txt",
  "./example/test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### 5. 删除文件
```dart
await Client().deleteObject("test.txt");
```

### 6. 批量上传文件
```dart
await Client().putObjects(
  [
    AssetEntity(filename: "filename1.txt", bytes: "files1".codeUnits),
    AssetEntity(filename: "filename2.txt", bytes: "files2".codeUnits),
  ],
  onSendProgress: (count, total) {
    debugPrint("sent = $count, total = $total");
  },
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### 7. 批量删除文件
```dart
await Client().deleteObjects(["filename1.txt", "filename2.txt"]);
```

### 8. 获取已签名的文件url，这个url可以直接在浏览器访问
需要注意的是：这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短

```dart
final String url = await Client().getSignedUrl("filename1.txt");
```

### 9. 获取多个已签名的文件url
需要注意的是：这个操作并`不安全`，因为url包含security-token信息，即使过期时间比较短

```dart
final Map<String, String> result = await Client().getSignedUrls(["test.txt", "filename1.txt"]);
```

### 10. 列举存储空间中所有文件
接口用于列举存储空间（Bucket）中所有文件（Object）的信息。请求参数和返回结果，请参考：https://help.aliyun.com/document_detail/187544.html

```dart
final Response<dynamic> resp = await Client().listFiles({});
```

### 11. 获取bucket信息
查看存储空间（Bucket）的相关信息。返回结果请参考：https://help.aliyun.com/document_detail/31968.html

```dart
final Response<dynamic> resp = await Client().getBucketInfo();
```

### 12. 获取bucket的储容量以及文件数量
获取指定存储空间（Bucket）的存储容量以及文件（Object）数量。返回结果请参考：https://help.aliyun.com/document_detail/426056.html

```dart
final Response<dynamic> resp = await Client().getBucketStat();
```

## Drop a ⭐ if it is help to you.
