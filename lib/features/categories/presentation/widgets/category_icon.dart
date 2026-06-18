import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/service_category.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.category,
    this.size = 20,
    this.color,
    this.fallbackIcon = Icons.category_outlined,
    super.key,
  });

  final ServiceCategory category;
  final double size;
  final Color? color;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final iconUrl = category.iconUrl;
    if (iconUrl == null || iconUrl.isEmpty) {
      return Icon(fallbackIcon, size: size, color: color);
    }

    if (iconUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        iconUrl,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (_) => Icon(fallbackIcon, size: size, color: color),
      );
    }

    return Image.network(
      iconUrl,
      width: size,
      height: size,
      errorBuilder: (_, _, _) => Icon(fallbackIcon, size: size, color: color),
    );
  }
}
