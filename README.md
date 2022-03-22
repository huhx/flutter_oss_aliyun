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
- [ ] upload multiple objects at once
- [ ] delete multiple objects at once

## Usage
First, add `flutter_oss_aliyun` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^0.1.1
```
Don't forget to `flutter pub get`.

### 1. init the client
```dart
Client.init(
    stsUrl: "server url get sts token",
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucket name",
);
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

