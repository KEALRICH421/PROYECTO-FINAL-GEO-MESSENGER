class GeoNote {
  final String? id;
  final double lat;
  final double lng;
  final String message;
  final double radius;
  bool triggered;
  final String? userId; // ← NUEVO: ID del usuario que creó la nota

  GeoNote({
    this.id,
    required this.lat,
    required this.lng,
    required this.message,
    this.radius = 100.0,
    this.triggered = false,
    this.userId, // ← NUEVO
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'message': message,
      'radius': radius,
      'triggered': triggered,
      if (userId != null) 'userId': userId, // ← NUEVO: solo si no es null
    };
  }

  factory GeoNote.fromFirestore(Map<String, dynamic> data, String id) {
    return GeoNote(
      id: id,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      message: data['message'] as String? ?? '',
      radius: (data['radius'] as num?)?.toDouble() ?? 100.0,
      triggered: data['triggered'] as bool? ?? false,
      userId: data['userId'] as String?, // ← NUEVO
    );
  }
}
