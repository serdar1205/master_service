import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppFeedbackVariant { error, empty }

class AppFeedbackView extends StatelessWidget {
  const AppFeedbackView({
    required this.title,
    required this.message,
    required this.variant,
    this.icon,
    this.onPrimary,
    this.primaryLabel,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    super.key,
  });

  final String title;
  final String message;
  final AppFeedbackVariant variant;
  final IconData? icon;
  final VoidCallback? onPrimary;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _paletteFor(variant);
    final resolvedIcon = icon ?? palette.defaultIcon;

    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 520 : 360),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (!compact) ...[
                Positioned(
                  top: -18,
                  left: -12,
                  child: _DecorBlob(
                    size: 72,
                    color: palette.blobPrimary.withValues(alpha: 0.55),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: -16,
                  child: _DecorBlob(
                    size: 48,
                    color: palette.blobSecondary.withValues(alpha: 0.45),
                  ),
                ),
              ],
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 24,
                  compact ? 24 : 32,
                  compact ? 20 : 24,
                  compact ? 22 : 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(compact ? 18 : 22),
                  border: Border.all(color: AppColors.kFFE7EEF0),
                  boxShadow: compact
                      ? null
                      : const [
                          BoxShadow(
                            color: AppColors.k0A000000,
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: compact ? 72 : 88,
                      height: compact ? 72 : 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            palette.iconBackground,
                            palette.iconBackgroundEnd,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.iconBorder),
                      ),
                      child: Icon(
                        resolvedIcon,
                        color: palette.iconColor,
                        size: compact ? 34 : 42,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.kFF242B2F,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 18 : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.kFF6D7A82,
                        height: 1.45,
                        fontSize: compact ? 14 : null,
                      ),
                    ),
                    if (onPrimary != null && primaryLabel != null) ...[
                      SizedBox(height: compact ? 20 : 26),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onPrimary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.buttonColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(0, compact ? 46 : 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          icon: Icon(palette.primaryIcon, size: 20),
                          label: Text(primaryLabel!),
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
                            color: palette.buttonColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _FeedbackPalette _paletteFor(AppFeedbackVariant variant) {
    return switch (variant) {
      AppFeedbackVariant.error => const _FeedbackPalette(
        defaultIcon: Icons.cloud_off_rounded,
        primaryIcon: Icons.refresh_rounded,
        iconBackground: Color(0xFFFFF5F5),
        iconBackgroundEnd: Color(0xFFFFECEC),
        iconBorder: AppColors.kFFF0D9DC,
        iconColor: AppColors.kFFB3262E,
        buttonColor: AppColors.primary,
        blobPrimary: Color(0xFFFFE8E8),
        blobSecondary: Color(0xFFFFF0F0),
      ),
      AppFeedbackVariant.empty => const _FeedbackPalette(
        defaultIcon: Icons.inbox_rounded,
        primaryIcon: Icons.add_rounded,
        iconBackground: Color(0xFFEAF3FF),
        iconBackgroundEnd: Color(0xFFE3F3F3),
        iconBorder: Color(0xFFD9E8FF),
        iconColor: AppColors.primary,
        buttonColor: AppColors.primary,
        blobPrimary: Color(0xFFE3F3F3),
        blobSecondary: Color(0xFFEAF3FF),
      ),
    };
  }
}

class _FeedbackPalette {
  const _FeedbackPalette({
    required this.defaultIcon,
    required this.primaryIcon,
    required this.iconBackground,
    required this.iconBackgroundEnd,
    required this.iconBorder,
    required this.iconColor,
    required this.buttonColor,
    required this.blobPrimary,
    required this.blobSecondary,
  });

  final IconData defaultIcon;
  final IconData primaryIcon;
  final Color iconBackground;
  final Color iconBackgroundEnd;
  final Color iconBorder;
  final Color iconColor;
  final Color buttonColor;
  final Color blobPrimary;
  final Color blobSecondary;
}

class _DecorBlob extends StatelessWidget {
  const _DecorBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
