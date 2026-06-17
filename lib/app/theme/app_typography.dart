import 'package:flutter/material.dart';

/// Mobile-first type scale tuned for dense service-app screens.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(TextTheme base) {
    TextStyle style(
      TextStyle? source, {
      required double size,
      FontWeight weight = FontWeight.w400,
      double height = 1.35,
      double? letterSpacing,
    }) {
      return (source ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      displayLarge: style(
        base.displayLarge,
        size: 28,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
      ),
      displayMedium: style(
        base.displayMedium,
        size: 24,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      displaySmall: style(
        base.displaySmall,
        size: 22,
        weight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      headlineLarge: style(
        base.headlineLarge,
        size: 20,
        weight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      headlineMedium: style(
        base.headlineMedium,
        size: 18,
        weight: FontWeight.w700,
        height: 1.28,
        letterSpacing: -0.15,
      ),
      headlineSmall: style(
        base.headlineSmall,
        size: 17,
        weight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: style(
        base.titleLarge,
        size: 16,
        weight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: style(
        base.titleMedium,
        size: 15,
        weight: FontWeight.w600,
        height: 1.35,
      ),
      titleSmall: style(
        base.titleSmall,
        size: 13,
        weight: FontWeight.w600,
        height: 1.35,
      ),
      bodyLarge: style(
        base.bodyLarge,
        size: 15,
        weight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: style(
        base.bodyMedium,
        size: 14,
        weight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: style(
        base.bodySmall,
        size: 12,
        weight: FontWeight.w400,
        height: 1.35,
      ),
      labelLarge: style(
        base.labelLarge,
        size: 13,
        weight: FontWeight.w600,
        height: 1.2,
      ),
      labelMedium: style(
        base.labelMedium,
        size: 12,
        weight: FontWeight.w500,
        height: 1.25,
      ),
      labelSmall: style(
        base.labelSmall,
        size: 11,
        weight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}
