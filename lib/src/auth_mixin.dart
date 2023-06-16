import 'dart:async';

import 'model/auth.dart';

mixin AuthMixin {
  late final FutureOr<Auth> Function() authGetter;

  Auth? auth;

  /// get auth information from sts server
  Future<Auth> getAuth() async {
    if (isUnAuthenticated) {
      auth = await authGetter();
      return auth!;
    }
    return auth!;
  }

  /// whether auth is valid or not
  bool get isUnAuthenticated {
    return auth == null || auth!.isExpired;
  }
}
