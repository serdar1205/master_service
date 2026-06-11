import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/network/api_locale_holder.dart';
import 'package:master_service/core/network/locale_interceptor.dart';

void main() {
  test('adds X-Locale header from holder', () {
    final holder = ApiLocaleHolder(initialLocaleCode: 'ru');
    final interceptor = LocaleInterceptor(holder);
    final options = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers[ApiLocaleHolder.headerName], 'ru');
    expect(handler.wasCalled, isTrue);
  });

  test('ApiLocaleHolder normalizes unsupported codes to tk', () {
    final holder = ApiLocaleHolder(initialLocaleCode: 'en');
    expect(holder.localeCode, 'tk');
  });
}

class _CapturingRequestHandler extends RequestInterceptorHandler {
  bool wasCalled = false;

  @override
  void next(RequestOptions options) {
    wasCalled = true;
    super.next(options);
  }
}
