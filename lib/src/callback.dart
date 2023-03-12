import 'dart:convert';

import 'package:flutter_oss_aliyun/src/enums.dart';

class Callback {
  final String callbackUrl;
  final String? callbackHost;
  final String callbackBody;
  final CalbackBodyType? calbackBodyType;
  final Map<String, String>? callbackVar;

  Callback({
    required this.callbackUrl,
    this.callbackHost,
    required this.callbackBody,
    this.calbackBodyType = CalbackBodyType.url,
    this.callbackVar,
  });

  bool hasCallbackVar() {
    return callbackVar != null && callbackVar!.isNotEmpty;
  }

  Map<String, String> toHeaders() {
    return {
      "x-oss-callback": jsonCallback(),
      if (hasCallbackVar()) "x-oss-callback-var": jsonCallbackVar(),
    };
  }

  String jsonCallback() {
    assert(calbackBodyType != null);

    final Map<String, String> map = {
      "callbackUrl": callbackUrl,
      if (callbackHost != null && callbackHost!.isNotEmpty)
        "callbackHost": callbackHost!,
      "callbackBody": callbackBody,
      "callbackBodyType": calbackBodyType!.contentType,
    };
    final String encodeString = json.encode(map);

    return base64Encode(encodeString.codeUnits);
  }

  String jsonCallbackVar() {
    assert(callbackVar != null && callbackVar!.isNotEmpty);

    final String encodeString = json.encode(callbackVar);
    final String base64encodeString = base64Encode(encodeString.codeUnits);

    return base64encodeString.replaceAll("\n", "").replaceAll("\r", "");
  }
}
