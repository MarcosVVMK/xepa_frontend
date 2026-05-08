import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient(this.dio, this.tokenStorage) {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 40);
    dio.options.receiveTimeout = const Duration(seconds: 40);

    print('ApiClient inicializado com BaseURL: $baseUrl');

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('🌐 REQUISIÇÃO: [${options.method}] ${options.baseUrl}${options.path}');
          final token = await tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPOSTA: [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (e, handler) {
          print('❌ ERRO: [${e.response?.statusCode}] ${e.requestOptions.path}');
          print('📝 MENSAGEM: ${e.message}');
          print('📂 TIPO: ${e.type}');
          return handler.next(e);
        },
      ),
    );
  }
}
