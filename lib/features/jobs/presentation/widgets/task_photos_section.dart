import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/media/image_pick_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../application/job_details_cubit.dart';
import 'job_photo_slot.dart';

class TaskPhotosSection extends StatelessWidget {
  const TaskPhotosSection({
    required this.photoType,
    required this.title,
    required this.icon,
    super.key,
  });

  final String photoType;
  final String title;
  final IconData icon;

  static const _brandColor = AppColors.brand;
  static const _buttonColor = AppColors.buttonTeal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<JobDetailsCubit, JobDetailsState>(
      builder: (context, state) {
        final cubit = context.read<JobDetailsCubit>();
        final locked = state.isPhotoActionLocked;
        final availableSlots = cubit.availablePhotoSlots(photoType);
        final hasPending = state.hasPendingPhotos(photoType);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _brandColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF293237),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Expanded(
                    child: JobPhotoSlot(
                      label: '${l10n.text('photo')} ${index + 1}',
                      imageSource: cubit.photoAt(photoType, index),
                      isPending: cubit.isPendingPhoto(photoType, index),
                      pendingLabel: l10n.text('photoPending'),
                      onRemove:
                          cubit.isPendingPhoto(photoType, index) && !locked
                          ? () => cubit.removePendingPhoto(photoType, index)
                          : null,
                    ),
                  ),
                  if (index == 0) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: locked || availableSlots == 0
                        ? null
                        : () => _selectPhotos(context, l10n),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandColor,
                      side: const BorderSide(color: _brandColor),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.text('selectPhotos')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: locked || !hasPending
                        ? null
                        : () => _sendPhotos(context, l10n),
                    style: FilledButton.styleFrom(
                      backgroundColor: _buttonColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.text('sendPhotos')),
                  ),
                ),
              ],
            ),
            if (availableSlots == 0 && !hasPending)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.text('photosAllSlotsFilled'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6D7A82),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _selectPhotos(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<JobDetailsCubit>();
    final maxCount = cubit.availablePhotoSlots(photoType);
    if (maxCount == 0) {
      AppToast.showError(l10n.text('photosNoSlotsAvailable'));
      return;
    }

    if (!cubit.tryBeginPhotoPick()) {
      return;
    }

    List<String> paths = const [];
    try {
      paths = await ImagePickService.pickGalleryImages(maxCount: maxCount);
    } on PlatformException catch (error) {
      if (!context.mounted) {
        return;
      }

      final message = error.code == 'already_active'
          ? l10n.text('photosPickerBusy')
          : l10n.text('photosPickerFailed');
      AppToast.showError(message);
      return;
    } on Object {
      if (!context.mounted) {
        return;
      }

      AppToast.showError(l10n.text('photosPickerFailed'));
      return;
    } finally {
      cubit.endPhotoPick();
    }

    if (!context.mounted || paths.isEmpty) {
      return;
    }

    if (photoType == 'before') {
      cubit.setPendingBeforePhotos(paths);
    } else {
      cubit.setPendingAfterPhotos(paths);
    }
  }

  Future<void> _sendPhotos(BuildContext context, AppLocalizations l10n) async {
    final cubit = context.read<JobDetailsCubit>();
    final uploaded = await cubit.submitPhotos(photoType);
    if (!context.mounted) {
      return;
    }

    if (uploaded) {
      AppToast.showSuccess(l10n.text('photosUploadSuccess'));
      return;
    }

    final error = cubit.state.errorMessage;
    if (error != null) {
      AppToast.showError(error);
    }
  }
}
