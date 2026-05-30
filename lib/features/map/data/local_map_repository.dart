import 'package:latlong2/latlong.dart';

class MapMarkerItem {
  const MapMarkerItem({
    required this.point,
    required this.iconCode,
    required this.labelKey,
  });

  final LatLng point;
  final int iconCode;
  final String labelKey;
}

class MapOfferData {
  const MapOfferData({
    required this.id,
    required this.titleKey,
    required this.distanceKey,
    required this.priceText,
    required this.iconCode,
  });

  final String id;
  final String titleKey;
  final String distanceKey;
  final String priceText;
  final int iconCode;
}

class MapData {
  const MapData({
    required this.center,
    required this.markers,
    required this.offers,
  });

  final LatLng center;
  final List<MapMarkerItem> markers;
  final List<MapOfferData> offers;
}

class LocalMapRepository {
  const LocalMapRepository();

  Future<MapData> fetchMapData() async {
    return const MapData(
      center: LatLng(37.9415, 58.3794),
      markers: [
        MapMarkerItem(
          point: LatLng(37.9438, 58.362),
          iconCode: 0xe0b7,
          labelKey: 'newRequest',
        ),
        MapMarkerItem(
          point: LatLng(37.935, 58.397),
          iconCode: 0xecf8,
          labelKey: 'newRequest',
        ),
        MapMarkerItem(
          point: LatLng(37.925, 58.416),
          iconCode: 0xe9d0,
          labelKey: 'newRequest',
        ),
      ],
      offers: [
        MapOfferData(
          id: 'map-offer-1',
          titleKey: 'installSocket',
          distanceKey: 'distanceTime',
          priceText: '150\nTMT',
          iconCode: 0xe0b7,
        ),
        MapOfferData(
          id: 'map-offer-2',
          titleKey: 'mapOfferCleaning',
          distanceKey: 'distanceTime',
          priceText: '120\nTMT',
          iconCode: 0xecf8,
        ),
        MapOfferData(
          id: 'map-offer-3',
          titleKey: 'mapOfferHandyman',
          distanceKey: 'distanceTime',
          priceText: '200\nTMT',
          iconCode: 0xe9d0,
        ),
      ],
    );
  }
}
