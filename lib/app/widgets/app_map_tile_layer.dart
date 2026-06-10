import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// OpenStreetMap primary tiles with Carto Voyager fallback (no retina suffix).
class AppMapTileLayer extends StatelessWidget {
  const AppMapTileLayer({super.key, this.onTileError});

  static const userAgentPackageName = 'com.example.master_service';

  static const osmUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const cartoFallbackUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  final void Function(TileImage tile, Object error, StackTrace? stackTrace)?
  onTileError;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: osmUrlTemplate,
      fallbackUrl: cartoFallbackUrlTemplate,
      subdomains: const ['a', 'b', 'c', 'd'],
      userAgentPackageName: userAgentPackageName,
      errorTileCallback: onTileError,
    );
  }
}

class AppMapTileErrorBanner extends StatelessWidget {
  const AppMapTileErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_outlined, color: Color(0xFFE65100)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5D4037),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
