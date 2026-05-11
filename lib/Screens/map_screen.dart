import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final MapController _mapController = MapController();
  final List<GeoNote> _notes = [];

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

    if (!mounted) return;

    _currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {});

    _listenLocation();
  }

  /// Escucha cambios de ubicación
  void _listenLocation() {
    LocationManager.getLocationStream().listen((position) {
      if (!mounted) return;

      _currentPosition = LatLng(position.latitude, position.longitude);
      setState(() {});

      var activated = GeofenceService.evaluateGeofences(
        position.latitude,
        position.longitude,
        _notes,
      );

      for (var note in activated) {
        if (!mounted) return;
        NotificationService.showAlert(context, note.message);
      }
    });
  }

  void _deleteNote(int index) {
    _notes.removeAt(index);
    setState(() {});
  }

  void _showNoteDialog(int index) {
    final note = _notes[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.message),
        content: Text('Lat: ${note.lat}, Lng: ${note.lng}'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote(index);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Marker> get _noteMarkers {
    return List<Marker>.generate(
      _notes.length,
      (index) {
        final note = _notes[index];
        return Marker(
          point: LatLng(note.lat, note.lng),
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _showNoteDialog(index),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Marker> allMarkers = [
      ..._noteMarkers,
      if (_currentPosition != null)
        Marker(
          point: _currentPosition!,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 40,
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Geo Messenger PRO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: () => _addNote(_mapController.camera.center),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) => _addNote(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: allMarkers),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 80, // Above the FAB
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15.0);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
