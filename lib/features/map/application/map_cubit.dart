import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../../jobs/application/order_location_enricher.dart';
import '../../jobs/domain/order_models.dart';
import '../../jobs/domain/orders_repository.dart';
import '../application/map_marker_utils.dart';
import '../data/local_map_repository.dart';

class MapState {
  const MapState({required this.status, this.data, this.errorMessage});

  const MapState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final MapData? data;
  final String? errorMessage;

  MapState copyWith({
    AppStatus? status,
    MapData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MapState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MapCubit extends Cubit<MapState> {
  MapCubit(this._ordersRepository)
    : _locationEnricher = OrderLocationEnricher(_ordersRepository),
      super(const MapState.initial());

  final OrdersRepository _ordersRepository;
  final OrderLocationEnricher _locationEnricher;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final dashboard = await _ordersRepository.fetchDashboard();
      final enrichedJobs = await _locationEnricher.enrichAll(
        dashboard.activeJobs,
      );
      final currentLocation = await _resolveCurrentLocation();
      final mapCenter = _resolveMapCenter(enrichedJobs, currentLocation);
      final markers = <MapMarkerItem>[];

      for (final job in enrichedJobs) {
        if (job.latitude == null || job.longitude == null) {
          continue;
        }

        markers.add(
          MapMarkerItem(
            orderId: job.id,
            point: LatLng(job.latitude!, job.longitude!),
            clientInitial: clientInitialFromName(job.clientName ?? ''),
          ),
        );
      }

      final offers = enrichedJobs
          .map(
            (job) => MapOfferData(
              id: job.id,
              titleKey: job.title,
              distanceKey: job.address,
              priceText: job.priceText,
              iconCode: 0xe0b7,
              category: job.category,
              statusKey: job.statusKey,
              actionKey: job.actionKey,
              latitude: job.latitude,
              longitude: job.longitude,
            ),
          )
          .toList();

      emit(
        state.copyWith(
          status: AppStatus.success,
          data: MapData(
            mapCenter: mapCenter,
            currentLocation: currentLocation,
            markers: markers,
            offers: offers,
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: error is ApiException
              ? error.message
              : 'Karta maglumatlary ýüklenmedi.',
        ),
      );
    }
  }

  Future<LatLng?> _resolveCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        return LatLng(position.latitude, position.longitude);
      }
    } on Object {
      // Location unavailable — map still works without the marker.
    }

    return null;
  }

  LatLng _resolveMapCenter(
    List<JobListItem> activeJobs,
    LatLng? currentLocation,
  ) {
    if (currentLocation != null) {
      return currentLocation;
    }

    for (final job in activeJobs) {
      final lat = job.latitude;
      final lng = job.longitude;
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }

    return AppConfig.mapDefaultCenter;
  }
}
