import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/jobs_cubit.dart';
import '../../data/local_jobs_repository.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const _brandColor = Color(0xFF087D83);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => JobsCubit(const LocalJobsRepository())..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFB),
        body: SafeArea(
          child: Column(
            children: [
              _OrdersHeader(localizations: localizations),
              Expanded(
                child: BlocBuilder<JobsCubit, JobsState>(
                  builder: (context, state) {
                    if (state.status == AppStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == AppStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(state.errorMessage ?? ''),
                        ),
                      );
                    }

                    final data = state.data;
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      children: [
                        Text(
                          localizations.text('myJobsTitle'),
                          style: Theme.of(context).textTheme.headlineSmall
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
                        const SizedBox(height: 16),
                        _StatsRow(
                          localizations: localizations,
                          activeCount: data.activeCount.toString(),
                          completedCount: data.completedCount.toString(),
                        ),
                        const SizedBox(height: 16),
                        for (var i = 0; i < data.activeJobs.length; i++) ...[
                          _OrderCard(
                            category: data.activeJobs[i].category,
                            title: data.activeJobs[i].title,
                            address: data.activeJobs[i].address,
                            price: data.activeJobs[i].priceText,
                            status: localizations.text(
                              data.activeJobs[i].statusKey,
                            ),
                            actionLabel: localizations.text(
                              data.activeJobs[i].actionKey,
                            ),
                            accentIcon: i == 0
                                ? Icons.electrical_services
                                : i == 1
                                ? Icons.plumbing
                                : Icons.air,
                            photoColor: i == 0
                                ? const Color(0xFF94A69A)
                                : i == 1
                                ? const Color(0xFF8FBEC1)
                                : const Color(0xFFAFC8C3),
                            secondaryIcon: i == 1
                                ? Icons.chat_bubble_outline
                                : Icons.phone_outlined,
                            outlinedPrimary:
                                data.activeJobs[i].isOutlinedAction,
                            onPrimaryAction: () => context.go(
                              AppRoutes.jobDetailsPath(data.activeJobs[i].id),
                            ),
                            onSecondaryAction: () {},
                          ),
                          if (i != data.activeJobs.length - 1)
                            const SizedBox(height: 18),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          localizations.text('ordersHistory'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF101719),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.text('completedOrdersSubtitle'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF526168)),
                        ),
                        const SizedBox(height: 14),
                        _HistoryCard(
                          localizations: localizations,
                          job: data.historyJobs.first,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _OrdersBottomNavigation(
          localizations: localizations,
        ),
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
      height: 58,
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
          Text(
            'RU/TM',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF4E5B61),
              fontWeight: FontWeight.w700,
            ),
          ),
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
  });

  final AppLocalizations localizations;
  final String activeCount;
  final String completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: activeCount,
            label: 'Aktiw',
            icon: Icons.work_history_outlined,
            backgroundColor: JobsScreen._brandColor,
            foregroundColor: Colors.white,
            borderColor: JobsScreen._brandColor,
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
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
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
        borderRadius: BorderRadius.circular(9),
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
                                backgroundColor: JobsScreen._brandColor,
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.localizations, required this.job});

  final AppLocalizations localizations;
  final JobListItem job;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFDCE5E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderPhoto(
            price: job.priceText,
            color: Color(0xFF9FB8B9),
            accentIcon: Icons.plumbing,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryPill(label: job.category),
                    const Spacer(),
                    _StatusPill(label: localizations.text('completed')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF11191C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.navigation_outlined,
                      color: Color(0xFF536167),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.address,
                        style: TextStyle(
                          color: Color(0xFF536167),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.distanceText,
                        style: TextStyle(color: Color(0xFF526168)),
                      ),
                    ),
                    Text(
                      localizations.text('report'),
                      style: const TextStyle(
                        color: Color(0xFF526168),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF526168),
                      size: 20,
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

class _OrdersBottomNavigation extends StatelessWidget {
  const _OrdersBottomNavigation({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_work_outlined,
                label: localizations.text('homeTab'),
                selected: false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _BottomNavItem(
                icon: Icons.handyman_outlined,
                label: localizations.text('ordersTab'),
                selected: true,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.map_outlined,
                label: localizations.text('mapTab'),
                selected: false,
                onTap: () => context.go(AppRoutes.map),
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: localizations.text('profileTab'),
                selected: false,
                onTap: () => context.go(AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? JobsScreen._brandColor : const Color(0xFF9AA7AD);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
