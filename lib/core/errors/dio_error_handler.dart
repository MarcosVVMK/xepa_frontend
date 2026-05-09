import 'package:dio/dio.dart';

class DioErrorHandler {
  DioErrorHandler._();

  static String extractMessage(
    DioException e, {
    String fallback = 'Erro desconhecido',
  }) {
    final data = e.response?.data;

    if (data != null && data is Map) {
      final detail = data['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;

        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }

        if (first is String) {
          return first;
        }
      }

      final error = data['error'];

      if (error is String && error.isNotEmpty) {
        return error;
      }

      final message = data['message'];
      
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }

    return fallback;
  }
}
