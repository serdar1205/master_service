import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/home_cubit.dart';
import '../../data/local_home_repository.dart';

class MasterHomeScreen extends StatelessWidget {
  const MasterHomeScreen({super.key});

  static const _brandColor = Color(0xFF4C9397);
  static const _buttonColor = Color(0xFF63C6CB);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => HomeCubit(const LocalHomeRepository())..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFB),
        body: BlocBuilder<HomeCubit, HomeState>(
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

            return CustomScrollView(
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
                            image: AssetImage('assets/image/header.png'),
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
                      _Greeting(localizations: localizations),
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
                      _CurrentJobCard(localizations: localizations),
                      const SizedBox(height: 20),
                      _SectionHeader(
                        title: localizations.text('newOrders'),
                        trailing: TextButton(
                          onPressed: () => context.go(AppRoutes.jobs),
                          child: Text(localizations.text('seeAll')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NewOrderCard(localizations: localizations),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            );
          },
        ),
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

        final bottomScrim = lerpDouble(0.42, 0.18, t)!;

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
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: lerpDouble(0.10, 0.04, t)!),
                    Colors.black.withValues(alpha: bottomScrim),
                  ],
                ),
              ),
            ),
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
              fontWeight: FontWeight.w900,
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
                          backgroundColor: MasterHomeScreen._buttonColor,
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
    return SizedBox(
      height: 144,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(37.938, 58.385),
                    initialZoom: 13.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.ustahyzmaty.master_service',
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.06)),
            ),
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
