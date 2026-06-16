import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class TaskPhotoSlot extends StatelessWidget {
  const TaskPhotoSlot({
    required this.label,
    this.imageSource,
    this.isUploading = false,
    this.hasError = false,
    this.onTap,
    this.onRetry,
    this.enabled = true,
    super.key,
  });

  static const _emptySlotColor = Color(0xFF1E293B);

  final String label;
  final String? imageSource;
  final bool isUploading;
  final bool hasError;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageSource != null && imageSource!.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: hasImage ? Colors.transparent : _emptySlotColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: hasError
                  ? Border.all(color: Colors.red.shade400, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  _SlotImage(source: imageSource!)
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (isUploading)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                if (hasError && !isUploading)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: IconButton(
                        onPressed: onRetry,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotImage extends StatelessWidget {
  const _SlotImage({required this.source});

  final String source;

  bool get _isNetwork =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrokenImage(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    return Image.file(
      File(source),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _BrokenImage(),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1E293B),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.white.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
