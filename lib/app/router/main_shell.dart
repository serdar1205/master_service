import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selectedTab = switch (navigationShell.currentIndex) {
      1 => AppBottomTab.jobs,
      2 => AppBottomTab.map,
      3 => AppBottomTab.profile,
      _ => AppBottomTab.home,
    };

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        localizations: AppLocalizations.of(context),
        selectedTab: selectedTab,
        onTabSelected: (tab) {
          final index = switch (tab) {
            AppBottomTab.home => 0,
            AppBottomTab.jobs => 1,
            AppBottomTab.map => 2,
            AppBottomTab.profile => 3,
          };
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
