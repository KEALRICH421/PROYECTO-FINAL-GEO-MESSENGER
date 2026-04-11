import 'dart:math';
import '../Models/geo_note.dart';

/// Servicio encargado de calcular distancias y detectar proximidad.
/// Implementa la fórmula de Haversine.
class GeofenceService {

  /// Calcula la distancia entre dos coordenadas geográficas
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {

    const double R = 6371000; // radio de la Tierra en metros

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  /// Verifica qué notas deben activarse según la ubicación actual
  static List<GeoNote> evaluateGeofences(
      double lat, double lng, List<GeoNote> notes) {

    List<GeoNote> activated = [];

    for (var note in notes) {
      double distance = calculateDistance(lat, lng, note.lat, note.lng);

      // Condición de activación
      if (distance <= note.radius && !note.triggered) {
        note.triggered = true;
        activated.add(note);
      }
    }

    return activated;
  }
}