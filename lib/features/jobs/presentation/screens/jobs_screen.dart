import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../app/widgets/locale_badge.dart';
import '../../../../app/widgets/locale_change_listener.dart';
import '../../../../app/widgets/orders_refresh_listener.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../app/di/app_repositories.dart';
import '../../application/jobs_cubit.dart';
import '../../domain/orders_filter.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const _brandColor = AppColors.brand;
  static const _buttonColor = AppColors.buttonTeal;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) {
        final cubit = JobsCubit(repositories.ordersRepository);
        unawaited(
          cubit.load().then((_) {
            repositories.activeOrderHolder.updateFromDashboard(
              cubit.state.dashboard,
            );
          }),
        );
        return cubit;
      },
      child: Builder(
        builder: (context) {
          return OrdersRefreshListener(
            onRefreshRequested: () {
              final cubit = context.read<JobsCubit>();
              unawaited(
                cubit.load().then((_) {
                  repositories.activeOrderHolder.updateFromDashboard(
                    cubit.state.dashboard,
                  );
                }),
              );
            },
            child: LocaleChangeListener(
              onLocaleChanged: () {
                final cubit = context.read<JobsCubit>();
                unawaited(
                  cubit.load().then((_) {
                    repositories.activeOrderHolder.updateFromDashboard(
                      cubit.state.dashboard,
                    );
                  }),
                );
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF4FBFB),
                body: SafeArea(
                  child: Column(
                    children: [
                      _OrdersHeader(localizations: localizations),
                      Expanded(
                        child: BlocBuilder<JobsCubit, JobsState>(
                          builder: (context, state) {
                            Future<void> refreshJobs() async {
                              final cubit = context.read<JobsCubit>();
                              await cubit.load();
                              if (!context.mounted) {
                                return;
                              }
                              repositories.activeOrderHolder
                                  .updateFromDashboard(cubit.state.dashboard);
                            }

                            if (state.status == AppStatus.loading &&
                                state.dashboard == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.status == AppStatus.failure) {
                              return AppRefreshableBody(
                                onRefresh: refreshJobs,
                                child: AppErrorView(
                                  message:
                                      state.errorMessage ??
                                      localizations.text('errorDefaultMessage'),
                                  onRetry: refreshJobs,
                                ),
                              );
                            }

                            final dashboard = state.dashboard;
                            if (dashboard == null) {
                              return const SizedBox.shrink();
                            }

                            final jobs = state.jobs;
                            final isListLoading =
                                state.status == AppStatus.loading;

                            return AppRefreshIndicator(
                              onRefresh: refreshJobs,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  16,
                                ),
                                children: [
                                  Text(
                                    localizations.text('myJobsTitle'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: const Color(0xFF101719),
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.text('myJobsSubtitle'),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFF526168),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  _StatsRow(
                                    localizations: localizations,
                                    activeCount: state.activeCount.toString(),
                                    completedCount: state.completedCount
                                        .toString(),
                                    selectedFilter: state.filter,
                                    onFilterSelected: (filter) {
                                      context.read<JobsCubit>().setFilter(
                                        filter,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  if (isListLoading && jobs.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else if (jobs.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Text(
                                        localizations.text('placeholder'),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: const Color(0xFF6D7A82),
                                            ),
                                      ),
                                    )
                                  else
                                    for (var i = 0; i < jobs.length; i++) ...[
                                      _OrderCard(
                                        category: jobs[i].category,
                                        title: jobs[i].title,
                                        address: jobs[i].address,
                                        price: jobs[i].priceText,
                                        status: localizations.text(
                                          jobs[i].statusKey,
                                        ),
                                        actionLabel: localizations.text(
                                          jobs[i].actionKey,
                                        ),
                                        accentIcon: switch (i % 3) {
                                          0 => Icons.electrical_services,
                                          1 => Icons.plumbing,
                                          _ => Icons.air,
                                        },
                                        photoColor: switch (i % 3) {
                                          0 => const Color(0xFF94A69A),
                                          1 => const Color(0xFF8FBEC1),
                                          _ => const Color(0xFFAFC8C3),
                                        },
                                        secondaryIcon: jobs[i].isHistory
                                            ? Icons.description_outlined
                                            : i % 3 == 1
                                            ? Icons.chat_bubble_outline
                                            : Icons.phone_outlined,
                                        outlinedPrimary:
                                            jobs[i].isOutlinedAction,
                                        onPrimaryAction: () async {
                                          final job = jobs[i];
                                          if (job.actionKey == 'startJob') {
                                            final cubit = context
                                                .read<JobsCubit>();
                                            final started = await cubit
                                                .startOrder(job.id);
                                            if (started && context.mounted) {
                                              repositories.activeOrderHolder
                                                  .updateFromDashboard(
                                                    cubit.state.dashboard,
                                                  );
                                            }
                                            return;
                                          }
                                          if (context.mounted) {
                                            context.go(
                                              AppRoutes.jobDetailsPath(job.id),
                                            );
                                          }
                                        },
                                        onSecondaryAction: () {},
                                      ),
                                      if (i != jobs.length - 1)
                                        const SizedBox(height: 14),
                                    ],
                                  if (isListLoading && jobs.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: JobsScreen._brandColor,
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              localizations.text('appTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: JobsScreen._brandColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const LocaleBadge(brandColor: JobsScreen._brandColor),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.localizations,
    required this.activeCount,
    required this.completedCount,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final AppLocalizations localizations;
  final String activeCount;
  final String completedCount;
  final OrdersFilter selectedFilter;
  final ValueChanged<OrdersFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final activeSelected = selectedFilter == OrdersFilter.active;
    final historySelected = selectedFilter == OrdersFilter.history;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: activeCount,
            label: localizations.text('active'),
            icon: Icons.work_history_outlined,
            backgroundColor: activeSelected
                ? JobsScreen._brandColor
                : Colors.white,
            foregroundColor: activeSelected
                ? Colors.white
                : const Color(0xFF1B2327),
            borderColor: activeSelected
                ? JobsScreen._brandColor
                : const Color(0xFFD7E0E3),
            onTap: () => onFilterSelected(OrdersFilter.active),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: completedCount,
            label: localizations.text('completed'),
            icon: Icons.check_circle_outline,
            backgroundColor: historySelected
                ? JobsScreen._brandColor
                : Colors.white,
            foregroundColor: historySelected
                ? Colors.white
                : const Color(0xFF1B2327),
            borderColor: historySelected
                ? JobsScreen._brandColor
                : const Color(0xFFD7E0E3),
            onTap: () => onFilterSelected(OrdersFilter.history),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  icon,
                  color: foregroundColor.withValues(alpha: 0.9),
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.category,
    required this.title,
    required this.address,
    required this.price,
    required this.status,
    required this.actionLabel,
    required this.accentIcon,
    required this.photoColor,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    this.secondaryIcon = Icons.phone_outlined,
    this.outlinedPrimary = false,
  });

  final String category;
  final String title;
  final String address;
  final String price;
  final String status;
  final String actionLabel;
  final IconData accentIcon;
  final IconData secondaryIcon;
  final Color photoColor;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final bool outlinedPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderPhoto(price: price, color: photoColor, accentIcon: accentIcon),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryPill(label: category),
                    const Spacer(),
                    _StatusPill(label: status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF11191C),
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.navigation_outlined,
                      color: Color(0xFF536167),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF536167),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: outlinedPrimary
                          ? OutlinedButton(
                              onPressed: onPrimaryAction,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: JobsScreen._brandColor,
                                side: const BorderSide(
                                  color: JobsScreen._brandColor,
                                ),
                                minimumSize: const Size.fromHeight(43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            )
                          : FilledButton(
                              onPressed: onPrimaryAction,
                              style: FilledButton.styleFrom(
                                backgroundColor: JobsScreen._buttonColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: onSecondaryAction,
                      color: JobsScreen._brandColor,
                      icon: Icon(secondaryIcon),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPhoto extends StatelessWidget {
  const _OrderPhoto({
    required this.price,
    required this.color,
    required this.accentIcon,
  });

  final String price;
  final Color color;
  final IconData accentIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PhotoPainter(baseColor: color, accentIcon: accentIcon),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: JobsScreen._brandColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                price,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPainter extends CustomPainter {
  const _PhotoPainter({required this.baseColor, required this.accentIcon});

  final Color baseColor;
  final IconData accentIcon;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final wallPaint = Paint()..color = Colors.white.withValues(alpha: 0.26);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.52),
      wallPaint,
    );

    final floorPaint = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.52, size.width, size.height * 0.48),
      floorPaint,
    );

    final circlePaint = Paint()..color = Colors.white.withValues(alpha: 0.32);
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.55),
      34,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.73, size.height * 0.46),
      42,
      circlePaint,
    );

    final personPaint = Paint()..color = const Color(0xFF2C3E46);
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.34),
      12,
      personPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.27, size.height * 0.45, 52, 58),
        const Radius.circular(14),
      ),
      personPaint,
    );

    final toolPaint = Paint()
      ..color = const Color(0xFFEEF6F7)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.52),
      Offset(size.width * 0.76, size.height * 0.32),
      toolPaint,
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(accentIcon.codePoint),
        style: TextStyle(
          fontSize: 32,
          fontFamily: accentIcon.fontFamily,
          package: accentIcon.fontPackage,
          color: Colors.white.withValues(alpha: 0.76),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(canvas, Offset(size.width * 0.08, size.height * 0.12));
  }

  @override
  bool shouldRepaint(_PhotoPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.accentIcon != accentIcon;
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBFF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4290A3),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7FBF5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF426A63),
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}
