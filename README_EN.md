Language: [中文简体](README.md) | [English](README_EN.md)

# flutter_oss_aliyun

Oss aliyun plugin for flutter. Use sts policy to authenticate the user.

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## 🐱&nbsp;Feature
- [x] upload object 
- [x] get object 
- [x] save object in files
- [x] delete object
- [x] upload multiple objects at once
- [x] delete multiple objects at once
- [x] progress callback for uploading files
- [x] progress callback for downloading files
- [x] get signed url for file
- [x] get multiple signed urls for files
- [x] list buckets
- [x] list objects in bucket
- [x] get bucket info
- [x] get bucket stat


## 🎨&nbsp;Usage
First, add `flutter_oss_aliyun` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^4.1.5
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

### 8. get signed url that can be accessed in browser directly
This is `not safe` due to the url include the security-token information even it will expire in short time. Use it carefully!!!

```dart
final String url = await Client().getSignedUrl("filename1.txt");
```

### 9. get multiple signed urls 
This is `not safe` due to the url include the security-token information even it will expire in short time. Use it carefully!!!

```dart
final Map<String, String> result = await Client().getSignedUrls(["test.txt", "filename1.txt"]);
```

### 10. list buckets
list all owned buckets, refer to: https://help.aliyun.com/document_detail/31957.html

```dart
final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});
```

### 11. list objects
List the information of all files (Object) in the storage space (Bucket). The parameters and response, refer to: https://help.aliyun.com/document_detail/187544.html

```dart
final Response<dynamic> resp = await Client().listFiles({});
```

### 12. get bucket info
View bucket information, The response refer to：https://help.aliyun.com/document_detail/31968.html

```dart
final Response<dynamic> resp = await Client().getBucketInfo();
```

### 13. get objects counts and bucket details
Gets the storage capacity of the specified storage space (Bucket) and the number of files (Object), The response refer to：https://help.aliyun.com/document_detail/426056.html

```dart
final Response<dynamic> resp = await Client().getBucketStat();
```

### 14. update object from local file

```dart
final Response<dynamic> resp = await Client().putObjectFile(File("/Users/aaa.pdf"));
```

## Drop a ⭐ if it is help to you.
