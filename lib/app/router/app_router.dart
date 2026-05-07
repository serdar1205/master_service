import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_cubit.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/categories/presentation/screens/category_setup_screen.dart';
import '../../features/jobs/presentation/screens/job_history_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/master_profile/presentation/screens/master_home_screen.dart';
import '../../features/master_profile/presentation/screens/profile_setup_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter(this._authCubit)
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
          path: AppRoutes.profileSetup,
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.categorySetup,
          builder: (context, state) => const CategorySetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MasterHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.jobs,
          builder: (context, state) => const JobsScreen(),
        ),
        GoRoute(
          path: AppRoutes.jobDetails,
          builder: (context, state) => const JobDetailsScreen(),
        ),
        GoRoute(
          path: AppRoutes.map,
          builder: (context, state) => const MapScreen(),
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
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Master Service')),
        body: const Center(
          child: Text('Something went wrong. Please reopen this section.'),
        ),
      ),
    );
  }

  final AuthCubit _authCubit;
  final GoRouterRefreshStream _refreshStream;

  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    final location = state.uri.path;
    final isAuthRoute =
        location == AppRoutes.phoneLogin ||
        location == AppRoutes.otp ||
        location == AppRoutes.splash;

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.restoring) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (authState.status == AuthStatus.otpRequested) {
      return location == AppRoutes.otp ? null : AppRoutes.otp;
    }

    if (!authState.isAuthenticated) {
      return location == AppRoutes.phoneLogin ? null : AppRoutes.phoneLogin;
    }

    if (!authState.profileComplete) {
      return location == AppRoutes.profileSetup ? null : AppRoutes.profileSetup;
    }

    if (!authState.categoriesComplete) {
      return location == AppRoutes.categorySetup
          ? null
          : AppRoutes.categorySetup;
    }

    if (isAuthRoute ||
        location == AppRoutes.profileSetup ||
        location == AppRoutes.categorySetup) {
      return AppRoutes.home;
    }

    return null;
  }

  void dispose() {
    _refreshStream.dispose();
    router.dispose();
  }
}
