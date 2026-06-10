import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'unauthorized_interceptor.dart';

class ApiClient {
  ApiClient({Dio? dio, SecureTokenStorage? tokenStorage})
    : dio = dio ?? _createDio(tokenStorage ?? SecureTokenStorage());

  final Dio dio;

  static Dio _createDio(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        sendTimeout: AppConfig.requestTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage));
    return dio;
  }

  void attachUnauthorizedHandler(UnauthorizedCallback onUnauthorized) {
    dio.interceptors.add(
      UnauthorizedInterceptor(onUnauthorized: onUnauthorized),
    );
  }
}
