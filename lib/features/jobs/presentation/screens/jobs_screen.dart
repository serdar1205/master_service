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
import '../../../../app/widgets/order_map_preview.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../app/di/app_repositories.dart';
import '../../../map/application/map_marker_utils.dart';
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
                                          fontWeight: FontWeight.w700,
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
                                        orderId: jobs[i].id,
                                        category: jobs[i].category,
                                        title: jobs[i].title,
                                        address: jobs[i].address,
                                        price: jobs[i].priceText,
                                        latitude: jobs[i].latitude,
                                        longitude: jobs[i].longitude,
                                        clientInitial: clientInitialFromName(
                                          jobs[i].clientName ?? '',
                                        ),
                                        status: localizations.text(
                                          jobs[i].statusKey,
                                        ),
                                        actionLabel: localizations.text(
                                          jobs[i].actionKey,
                                        ),
                                        showSecondaryAction: !jobs[i].isHistory,
                                        secondaryIcon: i % 3 == 1
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
                fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w700,
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
    required this.orderId,
    required this.category,
    required this.title,
    required this.address,
    required this.price,
    required this.clientInitial,
    required this.status,
    required this.actionLabel,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    this.latitude,
    this.longitude,
    this.showSecondaryAction = true,
    this.secondaryIcon = Icons.phone_outlined,
    this.outlinedPrimary = false,
  });

  final String orderId;
  final String category;
  final String title;
  final String address;
  final String price;
  final String clientInitial;
  final double? latitude;
  final double? longitude;
  final String status;
  final String actionLabel;
  final bool showSecondaryAction;
  final IconData secondaryIcon;
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
          OrderMapPreview(
            orderId: orderId,
            latitude: latitude,
            longitude: longitude,
            clientInitial: clientInitial,
            height: 108,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            topRight: orderMapPriceBadge(price),
          ),
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
                    fontWeight: FontWeight.w700,
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
                                minimumSize: const Size(0, 43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : FilledButton(
                              onPressed: onPrimaryAction,
                              style: FilledButton.styleFrom(
                                backgroundColor: JobsScreen._buttonColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    if (showSecondaryAction) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: onSecondaryAction,
                        color: JobsScreen._brandColor,
                        icon: Icon(secondaryIcon),
                      ),
                    ],
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
