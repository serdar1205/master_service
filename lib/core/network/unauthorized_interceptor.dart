import 'package:dio/dio.dart';

typedef UnauthorizedCallback = Future<void> Function();

class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({required UnauthorizedCallback onUnauthorized})
    : _onUnauthorized = onUnauthorized;

  final UnauthorizedCallback _onUnauthorized;
  bool _isHandling = false;

  static const _ignoredPathFragments = [
    '/auth/request-otp',
    '/auth/verify-otp',
    '/auth/logout',
  ];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode == 401 && !_shouldIgnore(path) && !_isHandling) {
      _isHandling = true;
      try {
        await _onUnauthorized();
      } finally {
        _isHandling = false;
      }
    }

    handler.next(err);
  }

  bool _shouldIgnore(String path) {
    for (final fragment in _ignoredPathFragments) {
      if (path.contains(fragment)) {
        return true;
      }
    }
    return false;
  }
}
