/// Modelo que representa una nota geolocalizada.
/// Contiene coordenadas, mensaje y configuración de activación.
class GeoNote {
  final double lat;
  final double lng;
  final String message;
  final double radius;

  bool triggered;

  GeoNote({
    required this.lat,
    required this.lng,
    required this.message,
    this.radius = 100,
    this.triggered = false,
  });

  /// Convierte el objeto a formato JSON (útil para persistencia futura)
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'message': message,
        'radius': radius,
        'triggered': triggered,
      };
}
