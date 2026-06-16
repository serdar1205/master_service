import 'package:latlong2/latlong.dart';

class MapMarkerItem {
  const MapMarkerItem({
    required this.orderId,
    required this.point,
    required this.clientInitial,
  });

  final String orderId;
  final LatLng point;
  final String clientInitial;
}

class MapOfferData {
  const MapOfferData({
    required this.id,
    required this.titleKey,
    required this.distanceKey,
    required this.priceText,
    required this.iconCode,
    required this.category,
    required this.statusKey,
    required this.actionKey,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String titleKey;
  final String distanceKey;
  final String priceText;
  final int iconCode;
  final String category;
  final String statusKey;
  final String actionKey;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;
}

class MapData {
  const MapData({
    required this.mapCenter,
    required this.markers,
    required this.offers,
    this.currentLocation,
  });

  final LatLng mapCenter;
  final LatLng? currentLocation;
  final List<MapMarkerItem> markers;
  final List<MapOfferData> offers;
}

class LocalMapRepository {
  const LocalMapRepository();

  Future<MapData> fetchMapData() async {
    return MapData(
      mapCenter: LatLng(37.9415, 58.3794),
      currentLocation: LatLng(37.9415, 58.3794),
      markers: [
        MapMarkerItem(
          orderId: 'map-offer-1',
          point: LatLng(37.9438, 58.362),
          clientInitial: 'A',
        ),
        MapMarkerItem(
          orderId: 'map-offer-2',
          point: LatLng(37.935, 58.397),
          clientInitial: 'G',
        ),
        MapMarkerItem(
          orderId: 'map-offer-3',
          point: LatLng(37.925, 58.416),
          clientInitial: 'S',
        ),
      ],
      offers: [
        MapOfferData(
          id: 'map-offer-1',
          titleKey: 'installSocket',
          distanceKey: 'distanceTime',
          priceText: '150\nTMT',
          iconCode: 0xe0b7,
          category: 'Electric',
          statusKey: 'assigned',
          actionKey: 'startJob',
          latitude: 37.9438,
          longitude: 58.362,
        ),
        MapOfferData(
          id: 'map-offer-2',
          titleKey: 'mapOfferCleaning',
          distanceKey: 'distanceTime',
          priceText: '120\nTMT',
          iconCode: 0xecf8,
          category: 'Cleaning',
          statusKey: 'assigned',
          actionKey: 'startJob',
          latitude: 37.935,
          longitude: 58.397,
        ),
        MapOfferData(
          id: 'map-offer-3',
          titleKey: 'mapOfferHandyman',
          distanceKey: 'distanceTime',
          priceText: '200\nTMT',
          iconCode: 0xe9d0,
          category: 'Handyman',
          statusKey: 'assigned',
          actionKey: 'startJob',
          latitude: 37.925,
          longitude: 58.416,
        ),
      ],
    );
  }
}
