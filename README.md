# flutter_oss_aliyun

Oss aliyun plugin for flutter. Use sts policy to authenticate the user.

## Feature has Supported
- [x] upload object 
- [x] get object 
- [x] save object in files

## Feature ready to Support
- [ ] List buckets
- [ ] callback when upload object
- [ ] upload multiple objects at once

## Usage
First, add `flutter_native_splash` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^0.0.7
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

