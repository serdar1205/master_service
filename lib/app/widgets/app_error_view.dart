import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.secondaryLabel,
    this.onSecondary,
    this.icon = Icons.cloud_off_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    super.key,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final resolvedTitle = title ?? l10n.text('errorTitle');
    final resolvedRetryLabel = retryLabel ?? l10n.text('retryAction');

    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7EEF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF0D9DC)),
                  ),
                  child: Icon(icon, color: AppColors.kFFB3262E, size: 42),
                ),
                const SizedBox(height: 22),
                Text(
                  resolvedTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF242B2F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6D7A82),
                    height: 1.45,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(resolvedRetryLabel),
                    ),
                  ),
                ],
                if (onSecondary != null && secondaryLabel != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(
                      secondaryLabel!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
