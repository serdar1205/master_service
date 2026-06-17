import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../app/widgets/locale_change_listener.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../app/di/app_repositories.dart';
import '../../../../app/widgets/app_map_tile_layer.dart';
import '../../application/map_cubit.dart';
import '../../data/local_map_repository.dart';
import '../widgets/map_location_markers.dart';
import '../widgets/map_order_bottom_sheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) => MapCubit(repositories.ordersRepository)..load(),
      child: Builder(
        builder: (context) {
          void openOrderSheet(MapOfferData offer) {
            MapOrderBottomSheet.show(
              context,
              orderId: offer.id,
              actionKey: offer.actionKey,
            );
          }

          return LocaleChangeListener(
            onLocaleChanged: () => context.read<MapCubit>().load(),
            child: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return AppRefreshIndicator(
                    onRefresh: () => context.read<MapCubit>().load(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        child: _ServiceMap(
                          localizations: localizations,
                          onOrderTap: openOrderSheet,
                        ),
                      ),
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

class _ServiceMap extends StatefulWidget {
  const _ServiceMap({required this.localizations, required this.onOrderTap});

  final AppLocalizations localizations;
  final void Function(MapOfferData offer) onOrderTap;

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
          return AppRefreshableBody(
            onRefresh: () => context.read<MapCubit>().load(),
            child: AppErrorView(
              message:
                  state.errorMessage ??
                  widget.localizations.text('errorDefaultMessage'),
              onRetry: () => context.read<MapCubit>().load(),
            ),
          );
        }

        final data = state.data;
        if (data == null) {
          return const SizedBox.shrink();
        }

        final offersById = {for (final offer in data.offers) offer.id: offer};

        return Stack(
          children: [
            FlutterMap(
              key: ValueKey(_mapRebuildKey),
              options: MapOptions(
                initialCenter: data.mapCenter,
                initialZoom: 13.2,
                minZoom: AppConfig.mapMinZoom,
                maxZoom: AppConfig.mapMaxZoom,
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
                        width: 48,
                        height: 56,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            final offer = offersById[marker.orderId];
                            if (offer != null) {
                              widget.onOrderTap(offer);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: ClientLocationMarker(
                            initial: marker.clientInitial,
                            orderId: marker.orderId,
                          ),
                        ),
                      ),
                    if (data.currentLocation != null)
                      Marker(
                        point: data.currentLocation!,
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const MyLocationMarker(),
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
