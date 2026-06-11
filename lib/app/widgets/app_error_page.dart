import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../router/app_routes.dart';
import 'app_error_view.dart';

class AppErrorPage extends StatelessWidget {
  const AppErrorPage({this.message, this.onRetry, super.key});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFB),
      body: SafeArea(
        child: AppErrorView(
          title: l10n.text('navigationErrorTitle'),
          message: message ?? l10n.text('navigationErrorMessage'),
          icon: Icons.explore_off_rounded,
          onRetry: onRetry ?? () => context.go(AppRoutes.home),
          retryLabel: l10n.text('goHomeAction'),
        ),
      ),
    );
  }
}
