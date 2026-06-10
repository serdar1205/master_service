import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/application/auth_cubit.dart';
import '../features/map/application/location_tracker.dart';
import 'di/app_repositories.dart';
import 'localization/app_localizations.dart';
import 'localization/tk_flutter_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MasterApp extends StatefulWidget {
  const MasterApp({
    super.key,
    required this.authCubit,
    required this.repositories,
    required this.locationTracker,
  });

  final AuthCubit authCubit;
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
    widget.authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRepositoriesScope(
      repositories: widget.repositories,
      child: BlocProvider<AuthCubit>.value(
        value: widget.authCubit,
        child: MaterialApp.router(
          title: 'Master Service',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _appRouter.router,
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
        ),
      ),
    );
  }
}
