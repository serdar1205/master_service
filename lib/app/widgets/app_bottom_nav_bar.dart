import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../router/app_routes.dart';

enum AppBottomTab { home, jobs, map, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.localizations,
    required this.selectedTab,
    super.key,
    this.onTabSelected,
    this.backgroundColor = Colors.white,
    this.borderRadius = BorderRadius.zero,
  });

  final AppLocalizations localizations;
  final AppBottomTab selectedTab;
  final ValueChanged<AppBottomTab>? onTabSelected;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  static const _brandColor = AppColors.brand;

  void _onTap(BuildContext context, AppBottomTab tab) {
    if (onTabSelected != null) {
      onTabSelected!(tab);
      return;
    }

    switch (tab) {
      case AppBottomTab.home:
        context.go(AppRoutes.home);
      case AppBottomTab.jobs:
        context.go(AppRoutes.jobs);
      case AppBottomTab.map:
        context.go(AppRoutes.map);
      case AppBottomTab.profile:
        context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.k12000000,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_work_outlined,
                label: localizations.text('homeTab'),
                selected: selectedTab == AppBottomTab.home,
                onTap: () => _onTap(context, AppBottomTab.home),
              ),
              _BottomNavItem(
                icon: Icons.handyman_outlined,
                label: localizations.text('ordersTab'),
                selected: selectedTab == AppBottomTab.jobs,
                onTap: () => _onTap(context, AppBottomTab.jobs),
              ),
              _BottomNavItem(
                icon: Icons.map_outlined,
                label: localizations.text('mapTab'),
                selected: selectedTab == AppBottomTab.map,
                onTap: () => _onTap(context, AppBottomTab.map),
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: localizations.text('profileTab'),
                selected: selectedTab == AppBottomTab.profile,
                onTap: () => _onTap(context, AppBottomTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppBottomNavBar._brandColor : AppColors.kFF9AA7AD;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
