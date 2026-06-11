import 'package:dio/dio.dart';

const skipErrorToastExtraKey = 'skip_error_toast';

class ApiErrorToastPolicy {
  const ApiErrorToastPolicy._();

  static bool shouldShow(DioException error) {
    if (error.requestOptions.extra[skipErrorToastExtraKey] == true) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return false;
    }

    final path = error.requestOptions.path;
    if (path.contains('/location')) {
      return false;
    }

    return true;
  }
}
