import 'package:mime/mime.dart';

mixin HttpMixin {
  String contentType(String filename) {
    return lookupMimeType(filename) ?? "application/octet-stream";
  }
}
