import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';
import 'api_error_toast_interceptor.dart';
import 'api_locale_holder.dart';
import 'auth_interceptor.dart';
import 'locale_interceptor.dart';
import 'unauthorized_interceptor.dart';

class ApiClient {
  ApiClient._({required this.dio, required this.localeHolder});

  factory ApiClient({
    Dio? dio,
    SecureTokenStorage? tokenStorage,
    ApiLocaleHolder? localeHolder,
  }) {
    final storage = tokenStorage ?? SecureTokenStorage();
    final holder = localeHolder ?? ApiLocaleHolder();

    return ApiClient._(
      dio: dio ?? _createDio(storage, holder),
      localeHolder: holder,
    );
  }

  final Dio dio;
  final ApiLocaleHolder localeHolder;

  static Dio _createDio(
    SecureTokenStorage tokenStorage,
    ApiLocaleHolder localeHolder,
  ) {
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

    dio.interceptors.add(LocaleInterceptor(localeHolder));
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(ApiErrorToastInterceptor());
    return dio;
  }

  void attachUnauthorizedHandler(UnauthorizedCallback onUnauthorized) {
    dio.interceptors.add(
      UnauthorizedInterceptor(onUnauthorized: onUnauthorized),
    );
  }
}
