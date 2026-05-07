import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/map_cubit.dart';
import '../../data/local_map_repository.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _brandColor = Color(0xFF087D83);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => MapCubit(const LocalMapRepository())..load(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _ServiceMap(localizations: localizations)),
            SafeArea(
              child: Column(
                children: [
                  _MapHeader(localizations: localizations),
                  const Spacer(),
                ],
              ),
            ),
            const Positioned(
              right: 18,
              top: 124,
              child: _MapControl(icon: Icons.my_location),
            ),
            const Positioned(
              right: 18,
              top: 188,
              child: _MapControl(icon: Icons.layers_outlined),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 76,
              child: _RequestSheet(localizations: localizations),
            ),
          ],
        ),
        bottomNavigationBar: _MapBottomNavigation(localizations: localizations),
      ),
    );
  }
}

class _ServiceMap extends StatelessWidget {
  const _ServiceMap({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
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

        return FlutterMap(
          options: MapOptions(
            initialCenter: data.center,
            initialZoom: 13.2,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.ustahyzmaty.master_service',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(37.9438, 58.362),
                  width: 138,
                  height: 48,
                  child: _JobMapMarker(
                    icon: Icons.bolt,
                    label: localizations.text('newRequest'),
                  ),
                ),
                Marker(
                  point: const LatLng(37.935, 58.397),
                  width: 138,
                  height: 48,
                  child: _JobMapMarker(
                    icon: Icons.cleaning_services_outlined,
                    label: localizations.text('newRequest'),
                  ),
                ),
                Marker(
                  point: const LatLng(37.925, 58.416),
                  width: 138,
                  height: 48,
                  child: _JobMapMarker(
                    icon: Icons.handyman_outlined,
                    label: localizations.text('newRequest'),
                  ),
                ),
                Marker(
                  point: data.center,
                  width: 132,
                  height: 108,
                  child: _CurrentLocationMarker(
                    label: localizations.text('yourLocation'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: MapScreen._brandColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.text('appTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: MapScreen._brandColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'RU/TM',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: MapScreen._brandColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF2E3B40), size: 24),
    );
  }
}

class _JobMapMarker extends StatelessWidget {
  const _JobMapMarker({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF8EBBFF),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1F4B93), size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF1C3153),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: MapScreen._brandColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_searching,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: MapScreen._brandColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestSheet extends StatelessWidget {
  const _RequestSheet({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E4E8),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.electrical_services,
                  color: MapScreen._brandColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.text('installSocket'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF172025),
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF66767D),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          localizations.text('distanceTime'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF66767D)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '150\nTMT',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: MapScreen._brandColor,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              localizations.text('cardNotCash'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF9AA7AD),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F6F7),
                    foregroundColor: const Color(0xFF30393D),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  child: Text(localizations.text('sleep')),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: MapScreen._brandColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(localizations.text('accept')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapBottomNavigation extends StatelessWidget {
  const _MapBottomNavigation({required this.localizations});

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
                selected: false,
                onTap: () => context.go(AppRoutes.jobs),
              ),
              _BottomNavItem(
                icon: Icons.map_outlined,
                label: localizations.text('mapTab'),
                selected: true,
                onTap: () {},
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
    final color = selected ? MapScreen._brandColor : const Color(0xFF9AA7AD);

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
