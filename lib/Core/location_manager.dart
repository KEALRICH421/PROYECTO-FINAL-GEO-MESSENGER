import 'package:geolocator/geolocator.dart';

/// Clase encargada de gestionar todo lo relacionado con ubicación.
/// Se separa para mantener limpio el código del UI.
class LocationManager {

  /// Solicita permisos de ubicación al usuario
  static Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado');
    }
  }

  /// Obtiene la ubicación actual del dispositivo
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Escucha cambios de ubicación en tiempo real
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // actualiza cada 10 metros
      ),
    );
  }
}
import 'package:geolocator/geolocator.dart';

/// Servicio encargado de manejar ubicación GPS
class LocationManager {

  /// Solicita permisos de ubicación
  static Future<void> requestPermission() async {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Los servicios de ubicación están desactivados',
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {

        throw Exception(
          'Permisos de ubicación denegados',
        );
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {

      throw Exception(
        'Permisos permanentemente denegados',
      );
    }
  }

  /// Obtener ubicación actual
  static Future<Position> getCurrentLocation() async {

    return await Geolocator.getCurrentPosition(

      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Stream ubicación tiempo real
  static Stream<Position> getLocationStream() {

    return Geolocator.getPositionStream(

      locationSettings: const LocationSettings(

        accuracy: LocationAccuracy.high,

        distanceFilter: 10,
      ),
    );
  }
}