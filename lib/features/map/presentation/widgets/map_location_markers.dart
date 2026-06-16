import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

Color avatarColorForOrder(String orderId) {
  const palette = <Color>[
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF14B8A6),
    Color(0xFF0EA5E9),
  ];

  return palette[orderId.hashCode.abs() % palette.length];
}

class MyLocationMarker extends StatelessWidget {
  const MyLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand.withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: AppColors.brand, width: 2.5),
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.brand,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class ClientLocationMarker extends StatelessWidget {
  const ClientLocationMarker({
    super.key,
    required this.initial,
    required this.orderId,
  });

  final String initial;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final avatarColor = avatarColorForOrder(orderId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                avatarColor,
                Color.lerp(avatarColor, Colors.black, 0.18)!,
              ],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _PinTailPainter(color: avatarColor),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
