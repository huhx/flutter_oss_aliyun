import 'dart:async';

import 'model/auth.dart';

mixin AuthMixin {
  late final FutureOr<Auth> Function() authGetter;

  Auth? auth;

  /// get auth information from sts server
  Future<Auth> getAuth() async {
    if (_isNotAuthenticated()) {
      if(authGetter is Future Function()) {
        auth = await authGetter();
      } else {
        auth = authGetter() as Auth;
      }
      return auth!;
    }
    return auth!;
  }

  /// whether auth is valid or not
  bool _isNotAuthenticated() {
    return auth == null || auth!.isExpired;
  }
}
