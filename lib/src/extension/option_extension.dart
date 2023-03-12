import 'package:flutter_oss_aliyun/src/model/enums.dart';
import 'package:flutter_oss_aliyun/src/model/request_option.dart';

extension PutRequestOptionExtension on PutRequestOption? {
  bool get forbidOverride {
    return !(this?.override ?? true);
  }

  String get acl {
    return (this?.aclModel ?? AclMode.inherited).content;
  }

  String get storage {
    return (this?.storageType ?? StorageType.standard).content;
  }
}

extension CopyRequestOptionExtension on CopyRequestOption {
  bool get forbidOverride {
    return !(this.override ?? true);
  }

  String get acl {
    return (aclModel ?? AclMode.inherited).content;
  }

  String get storage {
    return (storageType ?? StorageType.standard).content;
  }
}
