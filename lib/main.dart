import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/di/app_repositories.dart';
import 'app/master_app.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/map/application/location_tracker.dart';

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

      final repositories = AppRepositories.create();
      final authCubit = AuthCubit(repositories.authRepository);
      repositories.apiClient.attachUnauthorizedHandler(
        authCubit.handleSessionExpired,
      );
      final locationTracker = LocationTracker(
        locationRepository: repositories.locationRepository,
        tokenStorage: repositories.tokenStorage,
        activeOrderHolder: repositories.activeOrderHolder,
      );

      authCubit.stream.listen((state) {
        if (state.isAuthenticated) {
          unawaited(locationTracker.start());
        } else {
          locationTracker.stop();
          repositories.activeOrderHolder.clear();
        }
      });

      runApp(
        MasterApp(
          authCubit: authCubit,
          repositories: repositories,
          locationTracker: locationTracker,
        ),
      );
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
