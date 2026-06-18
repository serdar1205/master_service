import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'app_feedback_view.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.onAction,
    this.actionLabel,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    super.key,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppFeedbackView(
      title: title ?? l10n.text('emptySectionTitle'),
      message: message ?? l10n.text('emptySectionMessage'),
      variant: AppFeedbackVariant.empty,
      icon: icon,
      onPrimary: onAction,
      primaryLabel: actionLabel,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      compact: compact,
      padding: padding,
    );
  }
}
