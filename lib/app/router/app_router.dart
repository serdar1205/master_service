import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_cubit.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/jobs/presentation/screens/job_history_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/master_profile/presentation/screens/master_home_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/settings/presentation/screens/account_settings_screen.dart';
import '../../features/settings/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/settings/presentation/screens/payment_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terms_screen.dart';
import '../../features/settings/presentation/screens/support_screen.dart';
import '../di/app_repositories.dart';
import '../widgets/app_error_page.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import 'main_shell.dart';

class AppRouter {
  AppRouter(this._authCubit, this._repositories)
    : _refreshStream = GoRouterRefreshStream(_authCubit.stream) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _refreshStream,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.phoneLogin,
          builder: (context, state) => const PhoneLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) => const OtpVerificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.terms,
          builder: (context, state) =>
              TermsScreen(repository: _repositories.appSettingsRepository),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const MasterHomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.jobs,
                  builder: (context, state) => const JobsScreen(),
                  routes: [
                    GoRoute(
                      path: ':jobId',
                      builder: (context, state) => const JobDetailsScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.map,
                  builder: (context, state) => const MapScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.settings,
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.history,
          builder: (context, state) => const JobHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.payments,
          builder: (context, state) => const PaymentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.accountSettings,
          builder: (context, state) => const AccountSettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.languageSettings,
          builder: (context, state) => const LanguageSettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.paymentHistory,
          builder: (context, state) => const PaymentHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.supportCenter,
          builder: (context, state) => const SupportScreen(),
        ),
      ],
      errorBuilder: (context, state) =>
          AppErrorPage(message: state.error?.toString()),
    );
  }

  final AuthCubit _authCubit;
  final AppRepositories _repositories;
  final GoRouterRefreshStream _refreshStream;

  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    final location = state.uri.path;
    final isAuthRoute =
        location == AppRoutes.phoneLogin ||
        location == AppRoutes.otp ||
        location == AppRoutes.splash ||
        location == AppRoutes.terms;

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.restoring) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (authState.status == AuthStatus.otpRequested) {
      return location == AppRoutes.otp || location == AppRoutes.terms
          ? null
          : AppRoutes.otp;
    }

    if (!authState.isAuthenticated) {
      return location == AppRoutes.phoneLogin || location == AppRoutes.terms
          ? null
          : AppRoutes.phoneLogin;
    }

    if (isAuthRoute) {
      return AppRoutes.home;
    }

    return null;
  }

  void dispose() {
    _refreshStream.dispose();
    router.dispose();
  }
}
