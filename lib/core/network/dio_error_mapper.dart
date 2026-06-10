import 'package:dio/dio.dart';

import 'api_exception.dart';

class DioErrorMapper {
  const DioErrorMapper._();

  static ApiException map(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;
    final message = _extractMessage(response?.data) ?? _fallbackMessage(error);

    return ApiException(statusCode: statusCode, message: message);
  }

  static String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
        }
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  static String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => 'Connection timed out. Please try again.',
      DioExceptionType.connectionError =>
        'Could not reach the server. Check your connection.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
