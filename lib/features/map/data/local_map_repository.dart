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
    required this.titleKey,
    required this.distanceKey,
    required this.priceText,
  });

  final String titleKey;
  final String distanceKey;
  final String priceText;
}

class MapData {
  const MapData({
    required this.center,
    required this.markers,
    required this.offer,
  });

  final LatLng center;
  final List<MapMarkerItem> markers;
  final MapOfferData offer;
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
      offer: MapOfferData(
        titleKey: 'installSocket',
        distanceKey: 'distanceTime',
        priceText: '150\nTMT',
      ),
    );
  }
}
