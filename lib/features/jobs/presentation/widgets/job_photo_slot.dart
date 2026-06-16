import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class JobPhotoSlot extends StatelessWidget {
  const JobPhotoSlot({
    this.label,
    this.imageSource,
    this.isPending = false,
    this.pendingLabel,
    this.onTap,
    this.onRemove,
    this.enabled = true,
    super.key,
  });

  static const _brandColor = AppColors.brand;

  final String? label;
  final String? imageSource;
  final bool isPending;
  final String? pendingLabel;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final imageSource = this.imageSource;

    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _brandColor.withValues(
                alpha: imageSource == null ? 0.75 : 0,
              ),
              width: 1.4,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          foregroundDecoration: imageSource == null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _brandColor.withValues(alpha: 0.7),
                    width: 1.2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                )
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageSource != null)
                _JobPhotoImage(source: imageSource)
              else
                const ColoredBox(color: Colors.white),
              if (imageSource == null)
                CustomPaint(painter: _DashedBorderPainter(color: _brandColor)),
              if (imageSource == null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        color: _brandColor,
                        size: 27,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF6D7A82),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              if (isPending)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pendingLabel ?? '',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (onRemove != null)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobPhotoImage extends StatelessWidget {
  const _JobPhotoImage({required this.source});

  final String source;

  bool get _isNetworkSource {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkSource) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return Image.file(
      File(source),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PhotoPlaceholderPainter());
  }
}

class _PhotoPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFC5D6D9);
    canvas.drawRect(Offset.zero & size, paint);

    final accent = Paint()..color = const Color(0xFF9DB2B6);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.4), 26, accent);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.55,
          size.width * 0.5,
          size.height * 0.28,
        ),
        const Radius.circular(12),
      ),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 5.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
