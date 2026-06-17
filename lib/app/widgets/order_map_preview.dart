import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../features/map/presentation/widgets/map_location_markers.dart';
import '../localization/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import 'app_map_tile_layer.dart';

class OrderMapPreview extends StatelessWidget {
  const OrderMapPreview({
    required this.orderId,
    required this.clientInitial,
    this.latitude,
    this.longitude,
    this.height = 144,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(14)),
    this.topRight,
    super.key,
  });

  final String orderId;
  final String clientInitial;
  final double? latitude;
  final double? longitude;
  final double height;
  final BorderRadius borderRadius;
  final Widget? topRight;

  bool get _hasClientLocation => latitude != null && longitude != null;

  LatLng get _mapCenter => _hasClientLocation
      ? LatLng(latitude!, longitude!)
      : AppConfig.mapDefaultCenter;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: _hasClientLocation ? 14.5 : 12,
                    minZoom: AppConfig.mapMinZoom,
                    maxZoom: AppConfig.mapMaxZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    const AppMapTileLayer(),
                    if (_hasClientLocation)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _mapCenter,
                            width: 48,
                            height: 56,
                            alignment: Alignment.bottomCenter,
                            child: ClientLocationMarker(
                              initial: clientInitial,
                              orderId: orderId,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
            if (topRight != null)
              Positioned(top: 10, right: 10, child: topRight!),
            Positioned(
              right: 10,
              bottom: 8,
              child: Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => context.go(AppRoutes.map),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 14,
                          color: Color(0xFF101719),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          localizations.text('openMap'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF101719),
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget orderMapPriceBadge(String price) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      price,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}
