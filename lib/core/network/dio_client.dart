import 'package:dio/dio.dart';
import 'interceptors.dart';

// https://herbal-frown-unwashed.ngrok-free.dev
// http://192.168.0.100:800
class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://herbal-frown-unwashed.ngrok-free.dev",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(AppInterceptor());
}
