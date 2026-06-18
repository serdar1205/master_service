import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/widgets/app_toast.dart';
import '../features/auth/application/auth_cubit.dart';
import '../features/map/application/location_tracker.dart';
import 'di/app_repositories.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_cubit.dart';
import 'localization/tk_flutter_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MasterApp extends StatefulWidget {
  const MasterApp({
    super.key,
    required this.authCubit,
    required this.localeCubit,
    required this.repositories,
    required this.locationTracker,
  });

  final AuthCubit authCubit;
  final LocaleCubit localeCubit;
  final AppRepositories repositories;
  final LocationTracker locationTracker;

  @override
  State<MasterApp> createState() => _MasterAppState();
}

class _MasterAppState extends State<MasterApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(widget.authCubit);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    widget.locationTracker.dispose();
    unawaited(widget.repositories.masterRealtimeCoordinator.dispose());
    widget.authCubit.close();
    widget.localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRepositoriesScope(
      repositories: widget.repositories,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<LocaleCubit>.value(value: widget.localeCubit),
        ],
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              title: 'Master Service',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: AppToast.messengerKey,
              theme: AppTheme.light,
              routerConfig: _appRouter.router,
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                TkMaterialLocalizationsDelegate(),
                TkCupertinoLocalizationsDelegate(),
                TkWidgetsLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
