import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceCalculator {
  static const Distance _distance = Distance();

  static double calculateDistance(LatLng point1, LatLng point2) {
    return _distance.as(LengthUnit.Kilometer, point1, point2);
  }

  static bool isWithinRadius (
    LatLng center,
    LatLng point,
    double radiusKm,
  ) {
    return calculateDistance(center, point) <= radiusKm;
  }

  static String getDistanceString(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${(distanceKm.toStringAsFixed(1))} km';
    }
  }
}