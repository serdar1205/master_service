import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../app/di/app_repositories.dart';
import '../../../../app/widgets/app_map_tile_layer.dart';
import '../../application/map_cubit.dart';
import '../../data/local_map_repository.dart';

IconData _materialIcon(int code) => IconData(code, fontFamily: 'MaterialIcons');

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _brandColor = AppColors.brand;
  static const _buttonColor = AppColors.buttonTeal;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) => MapCubit(repositories.ordersRepository)..load(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _ServiceMap(localizations: localizations)),
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
              left: 0,
              right: 0,
              bottom: 76,
              child: BlocBuilder<MapCubit, MapState>(
                builder: (context, state) {
                  if (state.status != AppStatus.success) {
                    return const SizedBox.shrink();
                  }

                  final offers = state.data?.offers ?? const [];
                  if (offers.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return _MapOffersSlider(
                    localizations: localizations,
                    offers: offers,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceMap extends StatefulWidget {
  const _ServiceMap({required this.localizations});

  final AppLocalizations localizations;

  @override
  State<_ServiceMap> createState() => _ServiceMapState();
}

class _ServiceMapState extends State<_ServiceMap> {
  bool _tilesUnavailable = false;
  int _mapRebuildKey = 0;

  void _onTileError(TileImage tile, Object error, StackTrace? stackTrace) {
    if (_tilesUnavailable || !mounted) {
      return;
    }
    setState(() => _tilesUnavailable = true);
  }

  void _retryTiles() {
    setState(() {
      _tilesUnavailable = false;
      _mapRebuildKey++;
    });
  }

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

        return Stack(
          children: [
            FlutterMap(
              key: ValueKey(_mapRebuildKey),
              options: MapOptions(
                initialCenter: data.center,
                initialZoom: 13.2,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                AppMapTileLayer(onTileError: _onTileError),
                MarkerLayer(
                  markers: [
                    for (final marker in data.markers)
                      Marker(
                        point: marker.point,
                        width: 138,
                        height: 48,
                        child: _JobMapMarker(
                          icon: _materialIcon(marker.iconCode),
                          label: marker.labelKey,
                        ),
                      ),
                    Marker(
                      point: data.center,
                      width: 132,
                      height: 108,
                      child: _CurrentLocationMarker(
                        label: widget.localizations.text('yourLocation'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_tilesUnavailable)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 16,
                right: 16,
                child: AppMapTileErrorBanner(
                  message: widget.localizations.text('mapTilesError'),
                  onRetry: _retryTiles,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF2E3B40), size: 21),
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

class _MapOffersSlider extends StatelessWidget {
  const _MapOffersSlider({required this.localizations, required this.offers});

  final AppLocalizations localizations;
  final List<MapOfferData> offers;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 10),
        SizedBox(
          height: 218,
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final width = MediaQuery.sizeOf(context).width - 28;
              return SizedBox(
                width: width,
                child: _MapOrderCard(
                  localizations: localizations,
                  offer: offers[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MapOrderCard extends StatelessWidget {
  const _MapOrderCard({required this.localizations, required this.offer});

  final AppLocalizations localizations;
  final MapOfferData offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                child: Icon(
                  _materialIcon(offer.iconCode),
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
                      offer.titleKey,
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
                        Expanded(
                          child: Text(
                            offer.distanceKey,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF66767D)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                offer.priceText,
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
                    backgroundColor: MapScreen._buttonColor,
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
