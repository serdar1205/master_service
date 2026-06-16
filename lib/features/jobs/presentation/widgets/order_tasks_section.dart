import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/order_models.dart';
import 'job_photo_slot.dart';

class OrderTasksSection extends StatelessWidget {
  const OrderTasksSection({
    required this.tasks,
    required this.localizations,
    super.key,
  });

  final List<OrderTaskData> tasks;
  final AppLocalizations localizations;

  static const _brandColor = AppColors.brand;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.text('orderTasks'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF293237),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < tasks.length; i++) ...[
          _OrderTaskCard(
            index: i + 1,
            task: tasks[i],
            localizations: localizations,
          ),
          if (i != tasks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OrderTaskCard extends StatelessWidget {
  const _OrderTaskCard({
    required this.index,
    required this.task,
    required this.localizations,
  });

  final int index;
  final OrderTaskData task;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final hasBeforePhotos = task.beforePhotos.isNotEmpty;
    final hasAfterPhotos = task.afterPhotos.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: OrderTasksSection._brandColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF11191C),
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6D7A82),
                height: 1.35,
              ),
            ),
          ],
          if (hasBeforePhotos || hasAfterPhotos) ...[
            const SizedBox(height: 12),
            if (hasBeforePhotos) ...[
              _PhotoGroup(
                title: localizations.text('before'),
                photos: task.beforePhotos,
                localizations: localizations,
              ),
              if (hasAfterPhotos) const SizedBox(height: 10),
            ],
            if (hasAfterPhotos)
              _PhotoGroup(
                title: localizations.text('after'),
                photos: task.afterPhotos,
                localizations: localizations,
              ),
          ],
        ],
      ),
    );
  }
}

class _PhotoGroup extends StatelessWidget {
  const _PhotoGroup({
    required this.title,
    required this.photos,
    required this.localizations,
  });

  final String title;
  final List<OrderTaskPhoto> photos;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF526168),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < photos.length && i < 2; i++) ...[
              Expanded(
                child: JobPhotoSlot(
                  label: '${localizations.text('photo')} ${i + 1}',
                  imageSource: photos[i].url,
                  enabled: false,
                ),
              ),
              if (i == 0 && photos.length > 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}
