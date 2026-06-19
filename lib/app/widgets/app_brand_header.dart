import 'package:flutter/material.dart';

import 'app_brand_logo.dart';
import 'locale_badge.dart';

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    super.key,
    required this.title,
    required this.brandColor,
    this.height = 76,
    this.logoHeight = 54,
    this.horizontalPadding = 16,
    this.showShadow = true,
  });

  static const defaultHeight = 76.0;
  static const defaultLogoHeight = 54.0;

  final String title;
  final Color brandColor;
  final double height;
  final double logoHeight;
  final double horizontalPadding;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AppBrandLogo(height: logoHeight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: brandColor,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.1,
              ),
            ),
          ),
          LocaleBadge(brandColor: brandColor),
        ],
      ),
    );
  }
}
