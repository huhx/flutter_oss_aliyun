import 'package:dio/dio.dart';

class RestClient {
  static Dio getInstance() {
    return Dio(BaseOptions())
      ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
