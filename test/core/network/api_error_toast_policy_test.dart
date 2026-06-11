import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/network/api_error_toast_policy.dart';

void main() {
  DioException buildError({
    required String path,
    int? statusCode,
    Map<String, dynamic>? extra,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: path, extra: extra ?? const {}),
      response: statusCode == null
          ? null
          : Response(
              requestOptions: RequestOptions(path: path),
              statusCode: statusCode,
            ),
      type: DioExceptionType.badResponse,
    );
  }

  test('shows toast for validation errors', () {
    expect(
      ApiErrorToastPolicy.shouldShow(
        buildError(path: '/auth/request-otp', statusCode: 422),
      ),
      isTrue,
    );
  });

  test('skips 401 responses', () {
    expect(
      ApiErrorToastPolicy.shouldShow(buildError(path: '/me', statusCode: 401)),
      isFalse,
    );
  });

  test('skips background location pings', () {
    expect(
      ApiErrorToastPolicy.shouldShow(
        buildError(path: '/api/v1/master/12/location', statusCode: 500),
      ),
      isFalse,
    );
  });

  test('skips when request opts out', () {
    expect(
      ApiErrorToastPolicy.shouldShow(
        buildError(
          path: '/orders',
          statusCode: 422,
          extra: {skipErrorToastExtraKey: true},
        ),
      ),
      isFalse,
    );
  });
}
