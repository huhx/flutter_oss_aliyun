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


## 使用
添加依赖
```yaml
dependencies:
  flutter_oss_aliyun: ^3.0.2
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