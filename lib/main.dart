import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/master_app.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/secure_token_storage.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/auth/data/auth_repository_impl.dart';

void main() {
  const logger = ConsoleAppLogger();

  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        logger.error(
          'Unhandled Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        logger.error(
          'Unhandled platform error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      AppConfig.validateOrThrow(isDebugMode: kDebugMode);

      final tokenStorage = SecureTokenStorage();
      final authRepository = AuthRepositoryImpl(tokenStorage);
      final authCubit = AuthCubit(authRepository);

      runApp(MasterApp(authCubit: authCubit));
    },
    (error, stackTrace) {
      logger.error(
        'Unhandled zone error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
