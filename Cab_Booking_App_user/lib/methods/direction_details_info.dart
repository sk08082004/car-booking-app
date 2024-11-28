import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionDetailsInfo {
  final List<LatLng> ePoints;
  final int distanceValue;
  final int durationValue;
  final String distanceText;
  final String durationText;

  DirectionDetailsInfo({
    required this.ePoints,
    required this.distanceValue,
    required this.durationValue,
    required this.distanceText,
    required this.durationText,
  });
}
