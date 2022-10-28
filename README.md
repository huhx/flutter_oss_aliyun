Language: [English](README.md) | [中文简体](README_ZH.md)

# flutter_oss_aliyun

Oss aliyun plugin for flutter. Use sts policy to authenticate the user.

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## Feature
- [x] upload object 
- [x] get object 
- [x] save object in files
- [x] delete object
- [x] upload multiple objects at once
- [x] delete multiple objects at once
- [x] progress callback for uploading files
- [x] progress callback for downloading files


## Usage
First, add `flutter_oss_aliyun` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^3.0.2
```
Don't forget to `flutter pub get`.

### 1. init the client, we provide two ways to do it.
#### use sts server, just provide the sts url from our backend server:
```dart
Client.init(
    stsUrl: "server url get sts token",
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucket name",
);
```

This sts url api at least return the data:
```json
{
  "AccessKeyId": "AccessKeyId",
  "AccessKeySecret": "AccessKeySecret",
  "SecurityToken": "SecurityToken",
  "Expiration": "2022-03-22T11:33:06Z"
}
```

#### you can also customize the way to get sts json response.
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

### 2. put the object to oss with progress callback
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

### 3. get the object from oss with progress callback
```dart
await Client().getObject(
  "test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### 4. download the object from oss with progress callback
```dart
await Client().downloadObject(
  "test.txt", 
  "./example/test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### 5. delete the object from oss
```dart
await Client().deleteObject("test.txt");
```

### 6. batch put the object to oss
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

### 7. batch delete the object from oss
```dart
await Client().deleteObjects(["filename1.txt", "filename2.txt"]);
```