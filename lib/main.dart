import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/di/app_repositories.dart';
import 'app/localization/locale_cubit.dart';
import 'app/master_app.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_locale_storage.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/map/application/location_tracker.dart';

Future<void> main() async {
  const logger = ConsoleAppLogger();

  runZonedGuarded(
    () async {
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
      final localeStorage = AppLocaleStorage();
      final savedLocaleCode = await localeStorage.readLocaleCode();
      final deviceLocaleCode =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final localeCubit = LocaleCubit(
        storage: localeStorage,
        apiLocaleHolder: repositories.apiClient.localeHolder,
        initialLocale: LocaleCubit.resolveInitialLocale(
          savedLocaleCode: savedLocaleCode,
          deviceLocaleCode: deviceLocaleCode,
        ),
      );

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
          localeCubit: localeCubit,
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
