import 'dart:convert';

import 'enums.dart';

class Callback {
  const Callback({
    required this.callbackUrl,
    this.callbackHost,
    required this.callbackBody,
    this.callbackSNI,
    this.calbackBodyType = CalbackBodyType.url,
    this.callbackVar,
  });

  final String callbackUrl;
  final String? callbackHost;
  final String callbackBody;
  final bool? callbackSNI;
  final CalbackBodyType? calbackBodyType;
  final Map<String, String>? callbackVar;

  Map<String, String> toHeaders() {
    return {
      "x-oss-callback": _jsonCallback(),
      if (_hasCallbackVar) "x-oss-callback-var": _jsonCallbackVar(),
    };
  }

  String _jsonCallback() {
    assert(calbackBodyType != null);

    final Map<String, dynamic> map = {
      "callbackUrl": callbackUrl,
      if (_hasCallbackHost) "callbackHost": callbackHost!,
      "callbackBody": callbackBody,
      if (callbackSNI != null) "callbackSNI": callbackSNI,
      "callbackBodyType": calbackBodyType!.contentType,
    };
    final String encodeString = json.encode(map);

    return base64Encode(encodeString.codeUnits);
  }

  String _jsonCallbackVar() {
    assert(callbackVar != null && callbackVar!.isNotEmpty);

    final String encodeString = json.encode(callbackVar);
    final String base64encodeString = base64Encode(encodeString.codeUnits);

    return base64encodeString.replaceAll("\n", "").replaceAll("\r", "");
  }

  bool get _hasCallbackVar {
    return callbackVar != null && callbackVar!.isNotEmpty;
  }

  bool get _hasCallbackHost {
    return callbackHost != null && callbackHost!.isNotEmpty;
  }
}
