import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    debugPrint("REQUEST[${options.method}] => PATH: ${options.path}");
    debugPrint("DATA: ${options.data}");

    // Example: Add token automatically
    // options.headers["Authorization"] = "Bearer your_token";

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    debugPrint("RESPONSE[${response.statusCode}] => DATA: ${response.data}");

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    debugPrint("ERROR[${err.response?.statusCode}] => ${err.message}");

    super.onError(err, handler);
  }
}
