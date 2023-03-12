Language: [中文简体](README.md) | [English](README_EN.md)

# flutter_oss_aliyun

Oss aliyun plugin for flutter. Use sts policy to authenticate the user.

**flutter pub**: [https://pub.dev/packages/flutter_oss_aliyun](https://pub.dev/packages/flutter_oss_aliyun)

**oss sts document**: [https://help.aliyun.com/document_detail/100624.html](https://help.aliyun.com/document_detail/100624.html)

## 🐱&nbsp; Init Client
First, add `flutter_oss_aliyun` as a dependency in your `pubspec.yaml` file.
```yaml
dependencies:
  flutter_oss_aliyun: ^6.2.2
```
Don't forget to `flutter pub get`.

### **Init the client, we provide two ways to do it**
#### 1. `Use sts server api`: provide the sts url from our backend server:
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

#### 2. use authGetter
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

**`customize the dio`**

you can pass the dio in `init` method to use your own Dio.
```dart
Client.init(
    stsUrl: "server url get sts token",
    ossEndpoint: "oss-cn-beijing.aliyuncs.com",
    bucketName: "bucket name",
    dio: Dio(BaseOptions(connectTimeout: 9000)),
);
```

## 🎨&nbsp;Usage
- [put the object to oss with progress callback](#put-the-object-to-oss-with-progress-callback)
- [append object](#append-object)
- [copy object](#copy-object)
- [cancel file upload](#cancel-put-object)
- [batch put the object to oss](#batch-put-the-object-to-oss)
- [update object from local file](#update-object-from-local-file)
- [batch upload local files to oss](#batch-upload-local-files-to-oss)
- [get the object from oss with progress callback](#get-the-object-from-oss-with-progress-callback)
- [download the object from oss with progress callback](#download-the-object-from-oss-with-progress-callback)
- [delete the object from oss](#delete-the-object-from-oss)
- [batch delete the object from oss](#batch-delete-the-object-from-oss)
- [get signed url that can be accessed in browser directly](#get-signed-url-that-can-be-accessed-in-browser-directly)
- [get multiple signed urls](#get-multiple-signed-urls)
- [list buckets](#list-buckets)
- [list objects](#list-objects)
- [get bucket info](#get-bucket-info)
- [get objects counts and bucket details](#get-objects-counts-and-bucket-details)
- [get object metadata](#get-object-metadata)
- [query regions](#query-regions)
- [bucket acl](#bucket-acl)
- [bucket policy](#bucket-policy)

### **put the object to oss with progress callback**
callback reference: https://help.aliyun.com/document_detail/31989.htm?spm=a2c4g.11186623.0.0.73a830ffn45LMY#reference-zkm-311-hgb

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

**PutRequestOption, fields are optional**
| Filed       | Default value | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ----------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| override    | true          | true: Allow override the same name Object<br>false: Not allow override the same name Object                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| aclModel    | inherited     | 1. publicWrite: Anyone (including anonymous visitors) can read and write about the Object<br>2. publicRead: Only the owner of the Object can write to the Object, and anyone (including anonymous visitors) can read the Object<br>3. private: Only the owner of the Object can read and write to the Object, and no one else can access the Object<br>4. inherited: This Object follows the read and write permission of Bucket, which is what is Bucket and Object is what permission <br>reference: https://help.aliyun.com/document_detail/100676.htm?spm=a2c4g.11186623.0.0.56637952SnxOWV#concept-blw-yqm-2gb |
| storageType | Standard      | reference: https://help.aliyun.com/document_detail/51374.htm?spm=a2c4g.11186623.0.0.56632b55htpEQX#concept-fcn-3xt-tdb                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
### <span id="append-object">**append object**</span>
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

### <span id="copy-object">**copy object**</span>
```dart
final Response<dynamic> resp = await Client().copyObject(
  const CopyRequestOption(
    sourceFileKey: 'test.csv',
    targetFileKey: "test_copy.csv",
    targetBucketName: "bucket_2"
  ),
);
```

### <span id="cancel-put-object">**cancel file upload**</span>
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

### **batch put the object to oss**
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

### **update object from local file**

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
  ),
);
```

### **batch upload local files to oss**

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

### **get the object from oss with progress callback**
```dart
await Client().getObject(
  "test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### **download the object from oss with progress callback**
```dart
await Client().downloadObject(
  "test.txt", 
  "./example/test.txt",
  onReceiveProgress: (count, total) {
    debugPrint("received = $count, total = $total");
  },
);
```

### **delete the object from oss**
```dart
await Client().deleteObject("test.txt");
```

### **batch delete the object from oss**
```dart
await Client().deleteObjects(["filename1.txt", "filename2.txt"]);
```

### **get signed url that can be accessed in browser directly**
This is `not safe` due to the url include the security-token information even it will expire in short time. Use it carefully!!!

```dart
final String url = await Client().getSignedUrl("filename1.txt");
```

### **get multiple signed urls**
This is `not safe` due to the url include the security-token information even it will expire in short time. Use it carefully!!!

```dart
final Map<String, String> result = await Client().getSignedUrls(["test.txt", "filename1.txt"]);
```

### **list buckets**
list all owned buckets, refer to: https://help.aliyun.com/document_detail/31957.html

```dart
final Response<dynamic> resp = await Client().listBuckets({"max-keys": 2});
```

### **list objects**
List the information of all files (Object) in the storage space (Bucket). The parameters and response, refer to: https://help.aliyun.com/document_detail/187544.html

```dart
final Response<dynamic> resp = await Client().listFiles({});
```

### **get bucket info**
View bucket information, The response refer to: https://help.aliyun.com/document_detail/31968.html

```dart
final Response<dynamic> resp = await Client().getBucketInfo();
```

### **get objects counts and bucket details**
Gets the storage capacity of the specified storage space (Bucket) and the number of files (Object), The response refer to: https://help.aliyun.com/document_detail/426056.html

```dart
final Response<dynamic> resp = await Client().getBucketStat();
```

### **get object metadata**

```dart
final Response<dynamic> resp = await Client().getObjectMeta("huhx.csv");
```

### **query regions**
* find all

```dart
final Response<dynamic> resp = await Client().getAllRegions();
```

* find by name

```dart
final Response<dynamic> resp = await Client().getRegion("oss-ap-northeast-1");
```

### **bucket acl**
* query

```dart
final Response<dynamic> resp = await Client().getBucketAcl(
  bucketName: "bucket-name",
);
```

* add or update

```dart
final Response<dynamic> resp = await Client().putBucketAcl(
  AciMode.publicRead, 
  bucketName: "bucket-name",
);
```

### **bucket policy**
* query

```dart
final Response<dynamic> resp = await Client().getBucketPolicy(
  bucketName: "bucket-name",
);
```

* update

```dart
final Response<dynamic> resp = await Client().putBucketPolicy(
  {}, 
  bucketName: "bucket-name",
);
```

* delete
```dart
final Response<dynamic> resp = await Client().deleteBucketPolicy(
  bucketName: "bucket-name",
);
```

## Drop a ⭐ if it is help to you.
