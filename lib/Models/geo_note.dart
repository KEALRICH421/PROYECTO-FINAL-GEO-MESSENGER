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

class GeoNote {
  final String? id;

  final double lat;
  final double lng;

  final String message;

  final double radius;

  bool triggered;

  GeoNote({
    this.id,
    required this.lat,
    required this.lng,
    required this.message,
    this.radius = 100,
    this.triggered = false,
  });

  /// FIRESTORE → OBJETO
  factory GeoNote.fromFirestore(Map<String, dynamic> data, String id) {
    return GeoNote(
      id: id,
      lat: data['lat'],
      lng: data['lng'],
      message: data['message'],
      radius: data['radius'],
      triggered: data['triggered'],
    );
  }

  /// OBJETO → FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'message': message,
      'radius': radius,
      'triggered': triggered,
    };
  }
}
