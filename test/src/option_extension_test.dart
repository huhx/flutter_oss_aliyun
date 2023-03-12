import 'package:flutter_oss_aliyun/src/model/enums.dart';
import 'package:flutter_oss_aliyun/src/model/request_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_oss_aliyun/src/extension/option_extension.dart';

void main() {
  group("test override", () {
    test("option is null", () {
      const PutRequestOption? option = null;

      expect(option.forbidOverride, false);
    });

    test("override is null", () {
      const PutRequestOption option = PutRequestOption();

      expect(option.forbidOverride, false);
    });

    test("override is true", () {
      const PutRequestOption option = PutRequestOption(override: true);

      expect(option.forbidOverride, false);
    });

    test("override is false", () {
      const PutRequestOption option = PutRequestOption(override: false);

      expect(option.forbidOverride, true);
    });
  });

  group("test acl", () {
    test("option is null", () {
      const PutRequestOption? option = null;

      expect(option.acl, AclMode.inherited.content);
    });

    test("aclModel is null", () {
      const PutRequestOption option = PutRequestOption();

      expect(option.acl, AclMode.inherited.content);
    });

    test("aclModel is not null", () {
      const PutRequestOption option =
          PutRequestOption(aclModel: AclMode.private);

      expect(option.acl, AclMode.private.content);
    });
  });

  group("test storage type", () {
    test("option is null", () {
      const PutRequestOption? option = null;

      expect(option.storage, StorageType.standard.content);
    });

    test("storageType is null", () {
      const PutRequestOption option = PutRequestOption();

      expect(option.storage, StorageType.standard.content);
    });

    test("storageType is not null", () {
      const PutRequestOption option =
          PutRequestOption(storageType: StorageType.archive);

      expect(option.storage, StorageType.archive.content);
    });
  });
}
