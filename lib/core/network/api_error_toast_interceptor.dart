import 'package:dio/dio.dart';

import '../widgets/app_toast.dart';
import 'api_error_toast_policy.dart';
import 'dio_error_mapper.dart';

class ApiErrorToastInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiErrorToastPolicy.shouldShow(err)) {
      final apiException = DioErrorMapper.map(err);
      AppToast.showError(apiException.message);
    }

    handler.next(err);
  }
}
