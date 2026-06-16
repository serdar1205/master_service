import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/media/image_pick_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../application/job_details_cubit.dart';
import '../../domain/order_models.dart';
import 'full_screen_photo_viewer.dart';
import 'photo_source_bottom_sheet.dart';
import 'task_photo_slot.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.localizations,
    required this.canEdit,
    super.key,
  });

  final OrderTaskData task;
  final AppLocalizations localizations;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          BlocBuilder<JobDetailsCubit, JobDetailsState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _TaskPhotoSlotTile(
                      task: task,
                      type: 'before',
                      label: localizations.text('beforeShort'),
                      canEdit: canEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TaskPhotoSlotTile(
                      task: task,
                      type: 'after',
                      label: localizations.text('afterShort'),
                      canEdit: canEdit,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TaskPhotoSlotTile extends StatelessWidget {
  const _TaskPhotoSlotTile({
    required this.task,
    required this.type,
    required this.label,
    required this.canEdit,
  });

  final OrderTaskData task;
  final String type;
  final String label;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JobDetailsCubit>();
    final l10n = AppLocalizations.of(context);
    final imageSource = cubit.taskPhotoSource(task, type);
    final isUploading = cubit.isTaskPhotoUploading(task.id, type);
    final hasError = cubit.isTaskPhotoFailed(task.id, type);
    final hasImage = imageSource != null && imageSource.isNotEmpty;
    final slotEnabled = canEdit && cubit.canEditTaskPhoto(task, type, canEdit);

    return TaskPhotoSlot(
      label: label,
      imageSource: imageSource,
      isUploading: isUploading,
      hasError: hasError,
      enabled: slotEnabled,
      onRetry: hasError ? () => _retryUpload(context, cubit, l10n) : null,
      onTap: () =>
          _onSlotTap(context, cubit: cubit, l10n: l10n, hasImage: hasImage),
    );
  }

  Future<void> _onSlotTap(
    BuildContext context, {
    required JobDetailsCubit cubit,
    required AppLocalizations l10n,
    required bool hasImage,
  }) async {
    if (hasImage) {
      final source = cubit.taskPhotoSource(task, type);
      if (source != null) {
        await FullScreenPhotoViewer.show(context, source);
      }
      return;
    }

    if (!cubit.canAddTaskPhoto(task, type, canEdit)) {
      return;
    }

    final action = await PhotoSourceBottomSheet.show(context);
    if (action == null || !context.mounted) {
      return;
    }

    if (!cubit.beginTaskPhotoPick(task.id, type)) {
      return;
    }

    String? path;
    try {
      path = switch (action) {
        PhotoSourceAction.camera => await ImagePickService.pickCameraImage(),
        PhotoSourceAction.gallery => await ImagePickService.pickGalleryImage(),
      };
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

    if (!context.mounted || path == null) {
      return;
    }

    final uploaded = await cubit.uploadTaskPhoto(
      taskId: task.id,
      type: type,
      filePath: path,
    );

    if (!context.mounted) {
      return;
    }

    if (!uploaded) {
      _showUploadErrorSnackBar(context, l10n, cubit);
    }
  }

  Future<void> _retryUpload(
    BuildContext context,
    JobDetailsCubit cubit,
    AppLocalizations l10n,
  ) async {
    final uploaded = await cubit.retryTaskPhotoUpload(
      taskId: task.id,
      type: type,
    );

    if (!context.mounted) {
      return;
    }

    if (!uploaded) {
      _showUploadErrorSnackBar(context, l10n, cubit);
    }
  }

  void _showUploadErrorSnackBar(
    BuildContext context,
    AppLocalizations l10n,
    JobDetailsCubit cubit,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.text('photoUploadFailed')),
        action: SnackBarAction(
          label: l10n.text('retryAction'),
          onPressed: () {
            cubit.retryTaskPhotoUpload(taskId: task.id, type: type);
          },
        ),
      ),
    );
  }
}
