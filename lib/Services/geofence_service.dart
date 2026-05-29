import 'dart:math';

import '../Models/geo_note.dart';

class GeofenceService {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  static List<GeoNote> evaluateGeofences(double lat, double lng, List<GeoNote> notes) {
    final List<GeoNote> activated = [];
    for (final note in notes) {
      final distance = calculateDistance(lat, lng, note.lat, note.lng);
      if (distance <= note.radius && !note.triggered) {
        note.triggered = true;
        activated.add(note);
      }
    }
    return activated;
  }
}
