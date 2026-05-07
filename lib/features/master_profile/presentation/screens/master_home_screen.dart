import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/home_cubit.dart';
import '../../data/local_home_repository.dart';

class MasterHomeScreen extends StatelessWidget {
  const MasterHomeScreen({super.key});

  static const _brandColor = Color(0xFF087D83);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => HomeCubit(const LocalHomeRepository())..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFB),
        body: SafeArea(
          child: Column(
            children: [
              _HomeHeader(localizations: localizations),
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.status == AppStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == AppStatus.failure) {
                      return Center(child: Text(state.errorMessage ?? ''));
                    }

                    final data = state.data;
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      children: [
                        _Greeting(localizations: localizations),
                        const SizedBox(height: 18),
                        _StatsRow(
                          localizations: localizations,
                          activeCount: data.stats[0].value,
                          completedCount: data.stats[1].value,
                          earningsCount: data.stats[2].value,
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: localizations.text('currentJob'),
                          trailing: _StatusChip(
                            label: localizations.text('started'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CurrentJobCard(localizations: localizations),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: localizations.text('newOrders'),
                          trailing: TextButton(
                            onPressed: () => context.go(AppRoutes.jobs),
                            child: Text(localizations.text('seeAll')),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _NewOrderCard(localizations: localizations),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _HomeBottomNavigation(
          localizations: localizations,
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.localizations});

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
            color: MasterHomeScreen._brandColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              localizations.text('appTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: MasterHomeScreen._brandColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'RU/TM',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF4E5B61),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.text('homeGreeting'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF101719),
                  fontWeight: FontWeight.w900,
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
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFCFE3FF),
          child: Icon(Icons.person, color: Color(0xFF3B70D8), size: 34),
        ),
      ],
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
    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: earningsCount,
            label: localizations.text('earnings'),
            icon: Icons.account_balance_wallet_outlined,
            backgroundColor: const Color(0xFFD9E8FF),
            foregroundColor: const Color(0xFF3B629B),
            borderColor: const Color(0xFF9DBAEA),
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
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
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
          Icon(icon, color: foregroundColor.withValues(alpha: 0.9), size: 24),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
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
              fontWeight: FontWeight.w900,
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
  const _CurrentJobCard({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          _MapPreview(localizations: localizations),
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
                          const _CategoryPill(label: 'Santehnik'),
                          const SizedBox(height: 8),
                          Text(
                            'Suw akmasyny\ndüzetmek',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF11191C),
                                  fontWeight: FontWeight.w900,
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
                          '180\nTMT',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: MasterHomeScreen._brandColor,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.text('notCash'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF4B5960),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _LocationCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            context.go(AppRoutes.jobDetailsPath('job-2')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MasterHomeScreen._brandColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        child: Text(localizations.text('complete')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {},
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

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      decoration: const BoxDecoration(
        color: Color(0xFF55999A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
          const Positioned(
            left: 99,
            top: 72,
            child: _MapPin(
              icon: Icons.handyman_outlined,
              backgroundColor: Colors.white,
              iconColor: MasterHomeScreen._brandColor,
            ),
          ),
          Positioned(
            right: 71,
            top: 30,
            child: Column(
              children: [
                const _MapPin(
                  icon: Icons.person_outline,
                  backgroundColor: MasterHomeScreen._brandColor,
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    localizations.text('customer'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF101719),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 18,
            bottom: 14,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF101719),
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 20),
              label: Text(
                localizations.text('openMap'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: backgroundColor,
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final pointPaint = Paint()..color = const Color(0xFFDD6568);

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.18 + i * 0.16);
      final path = Path()
        ..moveTo(0, y)
        ..cubicTo(
          size.width * 0.22,
          y - 34,
          size.width * 0.48,
          y + 28,
          size.width,
          y - 18,
        );
      canvas.drawPath(path, linePaint);
    }

    const points = [
      Offset(166, 31),
      Offset(191, 23),
      Offset(214, 70),
      Offset(148, 83),
      Offset(117, 53),
    ];

    for (final point in points) {
      canvas.drawCircle(point, 3.2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_MapPatternPainter oldDelegate) => false;
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
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: MasterHomeScreen._brandColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4.2 km (8 min)',
                  style: TextStyle(
                    color: Color(0xFF11191C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Aşgabat ş., Parahat 4, 12-nji jaý',
                  style: TextStyle(color: Color(0xFF536167), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  const _NewOrderCard({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0E3)),
      ),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rozetka we lentalar',
                      style: TextStyle(
                        color: Color(0xFF101719),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Elektrik • 2.5 km uzaklykda',
                      style: TextStyle(color: Color(0xFF536167), fontSize: 12),
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
                    fontWeight: FontWeight.w900,
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
              const Expanded(
                child: Text(
                  '250 TMT',
                  style: TextStyle(
                    color: MasterHomeScreen._brandColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09B2BE),
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
                  localizations.text('accept'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                selected: true,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.handyman_outlined,
                label: localizations.text('ordersTab'),
                selected: false,
                onTap: () => context.go(AppRoutes.jobs),
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
    final color = selected
        ? MasterHomeScreen._brandColor
        : const Color(0xFF9AA7AD);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 25),
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
