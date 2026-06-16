import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/job_details_cubit.dart';
import '../../domain/order_models.dart';
import 'add_task_bottom_sheet.dart';
import 'task_card.dart';

class MyTasksSection extends StatefulWidget {
  const MyTasksSection({
    required this.tasks,
    required this.canEdit,
    required this.localizations,
    super.key,
  });

  final List<OrderTaskData> tasks;
  final bool canEdit;
  final AppLocalizations localizations;

  @override
  State<MyTasksSection> createState() => _MyTasksSectionState();
}

class _MyTasksSectionState extends State<MyTasksSection> {
  int _previousTaskCount = 0;

  @override
  void didUpdateWidget(covariant MyTasksSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousTaskCount = oldWidget.tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailsCubit, JobDetailsState>(
      builder: (context, state) {
        if (state.isTasksLoading) {
          return _TasksSkeleton(localizations: widget.localizations);
        }

        if (state.status == AppStatus.failure && state.data == null) {
          return _TasksError(
            message:
                state.errorMessage ??
                widget.localizations.text('tasksLoadFailed'),
            onRetry: () {
              final orderId = state.data?.id;
              if (orderId != null) {
                context.read<JobDetailsCubit>().load(orderId);
              }
            },
            localizations: widget.localizations,
          );
        }

        final tasks = widget.tasks;
        final isNewTask = tasks.length > _previousTaskCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.localizations.text('myTasks'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              _EmptyTasksState(
                localizations: widget.localizations,
                canEdit: widget.canEdit,
                onAdd: () => _openAddTask(context),
              )
            else ...[
              for (var i = 0; i < tasks.length; i++) ...[
                _AnimatedTaskEntry(
                  animate: isNewTask && i == tasks.length - 1,
                  child: TaskCard(
                    task: tasks[i],
                    localizations: widget.localizations,
                    canEdit: widget.canEdit,
                  ),
                ),
                if (i != tasks.length - 1) const SizedBox(height: 10),
              ],
              if (widget.canEdit) ...[
                const SizedBox(height: 10),
                _AddTaskButton(
                  localizations: widget.localizations,
                  onTap: () => _openAddTask(context),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Future<void> _openAddTask(BuildContext context) async {
    await AddTaskBottomSheet.show(context);
  }
}

class _AnimatedTaskEntry extends StatefulWidget {
  const _AnimatedTaskEntry({required this.child, required this.animate});

  final Widget child;
  final bool animate;

  @override
  State<_AnimatedTaskEntry> createState() => _AnimatedTaskEntryState();
}

class _AnimatedTaskEntryState extends State<_AnimatedTaskEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_opacity);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.localizations, required this.onTap});

  final AppLocalizations localizations;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  localizations.text('addTask'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState({
    required this.localizations,
    required this.canEdit,
    required this.onAdd,
  });

  final AppLocalizations localizations;
  final bool canEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 40,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.text('addFirstTask'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (canEdit) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(localizations.text('addTask')),
            ),
          ],
        ],
      ),
    );
  }
}

class _TasksSkeleton extends StatefulWidget {
  const _TasksSkeleton({required this.localizations});

  final AppLocalizations localizations;

  @override
  State<_TasksSkeleton> createState() => _TasksSkeletonState();
}

class _TasksSkeletonState extends State<_TasksSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.localizations.text('myTasks'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _shimmer,
          builder: (context, _) {
            return _ShimmerCard(progress: _shimmer.value);
          },
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _shimmer,
          builder: (context, _) {
            return _ShimmerCard(progress: _shimmer.value);
          },
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;
    final gradientShift = progress * 2 - 1;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment(-1 + gradientShift, 0),
          end: Alignment(gradientShift, 0),
          colors: [base, highlight, base],
        ),
      ),
    );
  }
}

class _TasksError extends StatelessWidget {
  const _TasksError({
    required this.message,
    required this.onRetry,
    required this.localizations,
  });

  final String message;
  final VoidCallback onRetry;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(localizations.text('retryAction')),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
