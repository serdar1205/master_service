import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
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

class _EnrichedMapJob {
  const _EnrichedMapJob({required this.job, required this.clientName});

  final JobListItem job;
  final String clientName;
}

class MapCubit extends Cubit<MapState> {
  MapCubit(this._ordersRepository) : super(const MapState.initial());

  final OrdersRepository _ordersRepository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final dashboard = await _ordersRepository.fetchDashboard();
      final enrichedJobs = await _enrichOrders(dashboard.activeJobs);
      final currentLocation = await _resolveCurrentLocation();
      final mapCenter = _resolveMapCenter(enrichedJobs, currentLocation);
      final markers = <MapMarkerItem>[];

      for (final entry in enrichedJobs) {
        final job = entry.job;
        if (job.latitude == null || job.longitude == null) {
          continue;
        }

        markers.add(
          MapMarkerItem(
            orderId: job.id,
            point: LatLng(job.latitude!, job.longitude!),
            clientInitial: clientInitialFromName(entry.clientName),
          ),
        );
      }

      final offers = enrichedJobs
          .map(
            (entry) => MapOfferData(
              id: entry.job.id,
              titleKey: entry.job.title,
              distanceKey: entry.job.address,
              priceText: entry.job.priceText,
              iconCode: 0xe0b7,
              category: entry.job.category,
              statusKey: entry.job.statusKey,
              actionKey: entry.job.actionKey,
              latitude: entry.job.latitude,
              longitude: entry.job.longitude,
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

  Future<List<_EnrichedMapJob>> _enrichOrders(List<JobListItem> jobs) async {
    final enriched = <_EnrichedMapJob>[];
    for (final job in jobs) {
      try {
        final details = await _ordersRepository.fetchOrder(job.id);
        enriched.add(
          _EnrichedMapJob(
            clientName: details.clientName,
            job: JobListItem(
              id: job.id,
              category: job.category,
              title: job.title,
              address: job.address,
              priceText: job.priceText,
              statusKey: job.statusKey,
              actionKey: job.actionKey,
              distanceText: job.distanceText,
              isOutlinedAction: job.isOutlinedAction,
              isHistory: job.isHistory,
              latitude: details.latitude ?? job.latitude,
              longitude: details.longitude ?? job.longitude,
            ),
          ),
        );
      } on Object {
        enriched.add(_EnrichedMapJob(job: job, clientName: ''));
      }
    }
    return enriched;
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
    List<_EnrichedMapJob> activeJobs,
    LatLng? currentLocation,
  ) {
    if (currentLocation != null) {
      return currentLocation;
    }

    for (final entry in activeJobs) {
      final lat = entry.job.latitude;
      final lng = entry.job.longitude;
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }

    return AppConfig.mapDefaultCenter;
  }
}
