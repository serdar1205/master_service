import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../../jobs/domain/order_models.dart';
import '../../jobs/domain/orders_repository.dart';
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
  MapCubit(this._ordersRepository) : super(const MapState.initial());

  final OrdersRepository _ordersRepository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final dashboard = await _ordersRepository.fetchDashboard();
      final jobsWithCoords = await _enrichWithCoordinates(dashboard.activeJobs);
      final center = await _resolveCenter(jobsWithCoords);
      final markers = <MapMarkerItem>[];

      for (final job in jobsWithCoords) {
        if (job.latitude == null || job.longitude == null) {
          continue;
        }
        markers.add(
          MapMarkerItem(
            point: LatLng(job.latitude!, job.longitude!),
            iconCode: 0xe0b7,
            labelKey: job.category,
          ),
        );
      }

      final offers = jobsWithCoords
          .map(
            (job) => MapOfferData(
              id: job.id,
              titleKey: job.title,
              distanceKey: job.address,
              priceText: job.priceText,
              iconCode: 0xe0b7,
            ),
          )
          .toList();

      emit(
        state.copyWith(
          status: AppStatus.success,
          data: MapData(center: center, markers: markers, offers: offers),
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

  Future<List<JobListItem>> _enrichWithCoordinates(
    List<JobListItem> jobs,
  ) async {
    final enriched = <JobListItem>[];
    for (final job in jobs) {
      if (job.latitude != null && job.longitude != null) {
        enriched.add(job);
        continue;
      }

      try {
        final details = await _ordersRepository.fetchOrder(job.id);
        enriched.add(
          JobListItem(
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
            latitude: details.latitude,
            longitude: details.longitude,
          ),
        );
      } on Object {
        enriched.add(job);
      }
    }
    return enriched;
  }

  Future<LatLng> _resolveCenter(List<JobListItem> activeJobs) async {
    for (final job in activeJobs) {
      final lat = job.latitude;
      final lng = job.longitude;
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }

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
      // Fall back to default map center when location is unavailable.
    }

    return const LatLng(37.9415, 58.3794);
  }
}
