import 'package:flutter_oss_aliyun/src/enums.dart';
import 'package:flutter_oss_aliyun/src/request_option.dart';

extension PutRequestOptionExtension on PutRequestOption? {
  bool get forbidOverwrite {
    return !(this?.override ?? true);
  }

  String get acl {
    return this?.aclModel?.content ?? AclMode.inherited.content;
  }

  String get storage {
    return this?.storageType?.content ?? StorageType.standard.content;
  }
}
