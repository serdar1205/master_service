import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_empty_view.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../app/widgets/locale_change_listener.dart';
import '../../../../app/widgets/order_map_preview.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../app/di/app_repositories.dart';
import '../../../jobs/domain/order_models.dart';
import '../../../jobs/presentation/utils/call_client_action.dart';
import '../../../map/application/map_marker_utils.dart';
import '../../application/home_cubit.dart';

class MasterHomeScreen extends StatelessWidget {
  const MasterHomeScreen({super.key});

  static const _brandColor = AppColors.brandLight;
  static const _buttonColor = AppColors.buttonTeal;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) {
        final cubit = HomeCubit(
          profileRepository: repositories.profileRepository,
          ordersRepository: repositories.ordersRepository,
        );
        unawaited(
          cubit.load().then((_) {
            final jobs = cubit.state.data?.activeJobs ?? const [];
            repositories.activeOrderHolder.updateFromActiveJobs(jobs);
          }),
        );
        return cubit;
      },
      child: Builder(
        builder: (context) {
          return LocaleChangeListener(
            onLocaleChanged: () {
              final cubit = context.read<HomeCubit>();
              unawaited(
                cubit.load().then((_) {
                  final jobs = cubit.state.data?.activeJobs ?? const [];
                  repositories.activeOrderHolder.updateFromActiveJobs(jobs);
                }),
              );
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF4FBFB),
              body: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  Future<void> refreshHome() async {
                    final cubit = context.read<HomeCubit>();
                    await cubit.load();
                    if (!context.mounted) {
                      return;
                    }
                    repositories.activeOrderHolder.updateFromActiveJobs(
                      cubit.state.data?.activeJobs ?? const [],
                    );
                  }

                  if (state.status == AppStatus.loading && state.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == AppStatus.failure) {
                    return AppRefreshableBody(
                      onRefresh: refreshHome,
                      child: AppErrorView(
                        message:
                            state.errorMessage ??
                            localizations.text('errorDefaultMessage'),
                        onRetry: refreshHome,
                      ),
                    );
                  }

                  final data = state.data;
                  if (data == null) {
                    return const SizedBox.shrink();
                  }

                  return AppRefreshIndicator(
                    onRefresh: refreshHome,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          forceMaterialTransparency: true,
                          expandedHeight: 132,
                          toolbarHeight: 58,
                          automaticallyImplyLeading: false,
                          titleSpacing: 0,
                          // Paint the image as the AppBar's own background so it shows when collapsed
                          backgroundColor: Colors.transparent,
                          title: const SizedBox.shrink(),
                          flexibleSpace: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Always-visible image — covers both collapsed and expanded states
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/image/header.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Animated overlay on top
                              FlexibleSpaceBar(
                                collapseMode: CollapseMode.parallax,
                                background: _AnimatedHomeHeader(
                                  localizations: localizations,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _Greeting(
                                localizations: localizations,
                                masterName: data.masterName,
                              ),
                              const SizedBox(height: 18),
                              _StatsRow(
                                localizations: localizations,
                                activeCount: data.stats[0].value,
                                completedCount: data.stats[1].value,
                                earningsCount: data.stats[2].value,
                              ),
                              const SizedBox(height: 20),
                              _SectionHeader(
                                title: localizations.text('currentJob'),
                                trailing: _StatusChip(
                                  label: localizations.text('started'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _CurrentJobsSlider(
                                localizations: localizations,
                                jobs: data.activeJobs,
                              ),
                              const SizedBox(height: 20),
                              _SectionHeader(
                                title: localizations.text('newOrders'),
                                trailing: TextButton(
                                  onPressed: () => context.go(AppRoutes.jobs),
                                  child: Text(localizations.text('seeAll')),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (data.activeJobs.isNotEmpty)
                                _NewOrderCard(
                                  localizations: localizations,
                                  job: data.activeJobs.first,
                                )
                              else
                                AppEmptyView(
                                  title: localizations.text(
                                    'emptyNewOrdersTitle',
                                  ),
                                  message: localizations.text(
                                    'emptyNewOrdersMessage',
                                  ),
                                  icon: Icons.notifications_none_rounded,
                                  compact: true,
                                  padding: EdgeInsets.zero,
                                ),
                            ]),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 160)),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.localizations, required this.masterName});

  final AppLocalizations localizations;
  final String? masterName;

  @override
  Widget build(BuildContext context) {
    final avatarLabel = _avatarInitial(masterName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.homeGreetingFor(masterName),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF101719),
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localizations.text('homeSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF536167),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFCFE3FF),
          child: avatarLabel == null
              ? const Icon(Icons.person, color: Color(0xFF3B70D8), size: 34)
              : Text(
                  avatarLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF3B70D8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }

  String? _avatarInitial(String? fullName) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _AnimatedHomeHeader extends StatelessWidget {
  const _AnimatedHomeHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        const minHeight = 58.0;
        const maxHeight = 132.0;
        final current = constraints.maxHeight - topInset;
        final rawT = ((current - minHeight) / (maxHeight - minHeight)).clamp(
          0.0,
          1.0,
        );
        final t = Curves.easeOutCubic.transform(rawT);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Expanded state image
            const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/header.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            // DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         Colors.black.withValues(alpha: lerpDouble(0.10, 0.04, t)!),
            //         Colors.black.withValues(alpha: bottomScrim),
            //       ],
            //     ),
            //   ),
            // ),
            // Blur effect on toolbar area
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: kToolbarHeight + topInset,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: lerpDouble(10, 3, t)!,
                      sigmaY: lerpDouble(10, 3, t)!,
                    ),
                    child: ColoredBox(
                      color: Colors.white.withValues(
                        alpha: lerpDouble(0.22, 0.10, t)!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom divider line
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: Colors.white.withValues(
                  alpha: lerpDouble(0.24, 0.0, t)!,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.localizations,
    required this.activeCount,
    required this.completedCount,
    required this.earningsCount,
  });

  final AppLocalizations localizations;
  final String activeCount;
  final String completedCount;
  final String earningsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatCard(
          value: earningsCount,
          label: localizations.text('earnings'),
          icon: Icons.account_balance_wallet_outlined,
          backgroundColor: const Color(0xFFD9E8FF),
          foregroundColor: const Color(0xFF3B629B),
          borderColor: const Color(0xFF9DBAEA),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: activeCount,
                label: localizations.text('active'),
                icon: Icons.work_history_outlined,
                backgroundColor: MasterHomeScreen._brandColor,
                foregroundColor: Colors.white,
                borderColor: MasterHomeScreen._brandColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: completedCount,
                label: localizations.text('completed'),
                icon: Icons.check_circle_outline,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B2327),
                borderColor: const Color(0xFFD7E0E3),
              ),
            ),
          ],
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
  });

  final String value;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor.withValues(alpha: 0.9), size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF101719),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 5,
          backgroundColor: MasterHomeScreen._brandColor,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF527075),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CurrentJobCard extends StatelessWidget {
  const _CurrentJobCard({required this.localizations, required this.job});

  final AppLocalizations localizations;
  final JobListItem job;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E0E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderMapPreview(
            orderId: job.id,
            latitude: job.latitude,
            longitude: job.longitude,
            clientInitial: clientInitialFromName(job.clientName ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CategoryPill(label: job.category),
                          const SizedBox(height: 8),
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF11191C),
                                  fontWeight: FontWeight.w700,
                                  height: 1.18,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          job.priceText,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: MasterHomeScreen._brandColor,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.text('notCash'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF4B5960),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LocationCard(address: job.address),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            context.go(AppRoutes.jobDetailsPath(job.id)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MasterHomeScreen._buttonColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        child: Text(localizations.text(job.actionKey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => callClientForJob(context, job),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MasterHomeScreen._brandColor,
                        minimumSize: const Size(58, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFD7E0E3)),
                      ),
                      child: const Icon(Icons.phone_outlined),
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

class _CurrentJobsSlider extends StatelessWidget {
  const _CurrentJobsSlider({required this.localizations, required this.jobs});

  final AppLocalizations localizations;
  final List<JobListItem> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return AppEmptyView(
        title: localizations.text('emptyCurrentJobsTitle'),
        message: localizations.text('emptyCurrentJobsMessage'),
        icon: Icons.handyman_outlined,
        compact: true,
        padding: EdgeInsets.zero,
      );
    }

    return SizedBox(
      height: 420,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: jobs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final job = jobs[index];
          final width = MediaQuery.sizeOf(context).width - 44;
          return SizedBox(
            width: width.clamp(280.0, 420.0),
            child: _CurrentJobCard(localizations: localizations, job: job),
          );
        },
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
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF4777A6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: MasterHomeScreen._brandColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(color: Color(0xFF536167), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  const _NewOrderCard({required this.localizations, required this.job});

  final AppLocalizations localizations;
  final JobListItem job;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderMapPreview(
            orderId: job.id,
            latitude: job.latitude,
            longitude: job.longitude,
            clientInitial: clientInitialFromName(job.clientName ?? ''),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 23,
                      backgroundColor: Color(0xFFE6FBF8),
                      child: Icon(
                        Icons.bolt,
                        color: MasterHomeScreen._brandColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              color: Color(0xFF101719),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${job.category} • ${job.address}',
                            style: const TextStyle(
                              color: Color(0xFF536167),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        localizations.text('newOrder'),
                        style: const TextStyle(
                          color: Color(0xFF101719),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFE2E8EA), height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.priceText,
                        style: const TextStyle(
                          color: MasterHomeScreen._brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () =>
                          context.go(AppRoutes.jobDetailsPath(job.id)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF63D5DA),
                        foregroundColor: const Color(0xFF083237),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        localizations.text(job.actionKey),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
