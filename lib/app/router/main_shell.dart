import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.child, required this.state, super.key});

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = state.uri.path;
    final selectedTab = switch (location) {
      final l when l == '/map' => AppBottomTab.map,
      final l when l == '/settings' => AppBottomTab.profile,
      final l when l == '/jobs' || l.startsWith('/jobs/') => AppBottomTab.jobs,
      _ => AppBottomTab.home,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        localizations: AppLocalizations.of(context),
        selectedTab: selectedTab,
      ),
    );
  }
}
