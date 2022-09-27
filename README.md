Language: [English](README.md) | [中文简体](README_ZH.md)

# flutter_oss_aliyun

Oss aliyun plugin for flutter. Use sts policy to authenticate the user.

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## Feature has Supported
- [x] upload object 
- [x] get object 
- [x] save object in files
- [x] delete object

## Feature ready to Support
- [ ] List buckets
- [ ] callback when upload object
- [x] upload multiple objects at once
- [x] delete multiple objects at once

## Usage
First, add `flutter_oss_aliyun` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^2.0.0
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

String _tokenGetterMethod() {
  return '''{
        "AccessKeyId": "access id",
        "AccessKeySecret": "AccessKeySecret",
        "SecurityToken": "security token",
        "Expiration": "2022-03-22T11:33:06Z"
    }''';
}
```

### 2. put the object to oss
```dart
final bytes = "file bytes".codeUnits;
await Client().putObject(bytes, "test.txt");
```

### 3. get the object from oss
```dart
await Client().getObject("test.txt");
```

### 4. download the object from oss
```dart
await Client().downloadObject("test.txt", "./example/test.txt");
```

### 5. delete the object from oss
```dart
await Client().deleteObject("test.txt");
```

