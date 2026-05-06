import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient(this.dio, this.tokenStorage) {
    String baseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 40);
    dio.options.receiveTimeout = const Duration(seconds: 40);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          dev.log('DIO REQUEST: [${options.method}] ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          dev.log('DIO RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (e, handler) {
          dev.log('DIO ERROR: [${e.response?.statusCode}] ${e.requestOptions.uri}', error: e);
          return handler.next(e);
        },
      ),
    );
  }
}
