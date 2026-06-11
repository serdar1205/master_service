import 'package:dio/dio.dart';

import 'api_locale_holder.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._localeHolder);

  final ApiLocaleHolder _localeHolder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[ApiLocaleHolder.headerName] = _localeHolder.localeCode;
    handler.next(options);
  }
}
