import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';

enum PhotoSourceAction { camera, gallery }

class PhotoSourceBottomSheet extends StatelessWidget {
  const PhotoSourceBottomSheet({super.key});

  static Future<PhotoSourceAction?> show(BuildContext context) {
    return showModalBottomSheet<PhotoSourceAction>(
      context: context,
      showDragHandle: true,
      builder: (_) => const PhotoSourceBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: Text(l10n.text('takePhoto')),
              onTap: () => Navigator.pop(context, PhotoSourceAction.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(l10n.text('chooseFromGallery')),
              onTap: () => Navigator.pop(context, PhotoSourceAction.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
