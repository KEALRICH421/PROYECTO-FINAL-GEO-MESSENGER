import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Core/location_manager.dart';
import '../Models/geo_note.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';
import '../widgets/note_dialog.dart';

/// Pantalla principal que contiene el mapa y la lógica principal
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  GoogleMapController? _mapController;

  final List<GeoNote> _notes = [];
  final Set<Marker> _markers = {};

  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Inicializa permisos y ubicación
  Future<void> _initialize() async {
    await LocationManager.requestPermission();
    var position = await LocationManager.getCurrentLocation();

    _currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {});

    _listenLocation();
  }

  /// Escucha cambios de ubicación
  void _listenLocation() {
    LocationManager.getLocationStream().listen((position) {

      var activated = GeofenceService.evaluateGeofences(
        position.latitude,
        position.longitude,
        _notes,
      );

      for (var note in activated) {
        NotificationService.showAlert(context, note.message);
      }
    });
  }

  /// Agrega una nueva nota al mapa
  void _addNote(LatLng position) async {
    String? message = await NoteDialog.show(context);

    if (message == null) return;

    GeoNote note = GeoNote(
      lat: position.latitude,
      lng: position.longitude,
      message: message,
    );

    _notes.add(note);

    _markers.add(
      Marker(
        markerId: MarkerId(message),
        position: position,
        infoWindow: InfoWindow(title: message),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Geo Messenger PRO")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        markers: _markers,
        onLongPress: _addNote,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}