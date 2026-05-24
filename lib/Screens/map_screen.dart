import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Core/location_manager.dart';
import '../Models/geo_note.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';
import '../widgets/note_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Core/location_manager.dart';
import '../Models/geo_note.dart';
import '../services/firestore_service.dart';
import '../widgets/note_dialog.dart';

/// Pantalla principal con mapa y notas geolocalizadas
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final FirestoreService _firestoreService =
      FirestoreService();

  final List<GeoNote> _notes = [];

  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Inicializa GPS y carga notas
  Future<void> _initialize() async {
    try {
      await LocationManager.requestPermission();

      _listenLocation();

      final position =
          await LocationManager.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(
          position.latitude,
          position.longitude,
        );
      });

      await _loadNotes();
    } catch (e) {
      debugPrint('ERROR INIT: $e');
    }
  }

  /// Escucha cambios de ubicación
  void _listenLocation() {
    LocationManager.getLocationStream().listen(
      (position) {
        if (!mounted) return;

        setState(() {
          _currentPosition = LatLng(
            position.latitude,
            position.longitude,
          );
        });
      },
      onError: (e) {
        debugPrint('LOCATION STREAM ERROR: $e');
      },
    );
  }

  /// Carga notas desde Firestore
  Future<void> _loadNotes() async {
    try {
      final loadedNotes =
          await _firestoreService.loadNotes();

      if (!mounted) return;

      setState(() {
        _notes.clear();
        _notes.addAll(loadedNotes);
      });
    } catch (e) {
      debugPrint('ERROR LOAD NOTES: $e');
    }
  }

  /// Agrega una nueva nota
  Future<void> _addNote(LatLng position) async {
    final message = await NoteDialog.show(context);

    if (message == null || message.trim().isEmpty) {
      return;
    }

    final note = GeoNote(
      lat: position.latitude,
      lng: position.longitude,
      message: message.trim(),
    );

    try {
      await _firestoreService.saveNote(note);

      if (!mounted) return;

      setState(() {
        _notes.add(note);
      });
    } catch (e) {
      debugPrint('ERROR SAVE NOTE: $e');
    }
  }

  /// Eliminar nota
  Future<void> _deleteNote(int index) async {
    try {
      final note = _notes[index];

      await _firestoreService.deleteNote(note);

      if (!mounted) return;

      setState(() {
        _notes.removeAt(index);
      });
    } catch (e) {
      debugPrint('ERROR DELETE NOTE: $e');
    }
  }

  /// Dialogo de información
  void _showNoteDialog(int index) {
    final note = _notes[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note.message),
        content: Text(
          'Lat: ${note.lat}\nLng: ${note.lng}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNote(index);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Marcadores de notas
  List<Marker> _buildMarkers() {
    return [
      ..._notes.asMap().entries.map(
        (entry) {
          final index = entry.key;
          final note = entry.value;

          return Marker(
            point: LatLng(note.lat, note.lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showNoteDialog(index),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        },
      ),

      /// Marcador ubicación actual
      if (_currentPosition != null)
        Marker(
          point: _currentPosition!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 40,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Messenger PRO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: () {
              _addNote(
                _mapController.camera.center,
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              initialZoom: 15,
              interactionOptions:
                  const InteractionOptions(
                flags: InteractiveFlag.all,
              ),

              /// Tap en mapa
              onTap: (tapPosition, point) {
                _addNote(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName:
                    'com.example.geomessenger',
              ),

              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),

          /// Botones zoom
          Positioned(
            right: 16,
            bottom: 90,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                FloatingActionButton(
                  heroTag: 'zoomOut',
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

      /// Centrar ubicación actual
      floatingActionButton: FloatingActionButton(
        heroTag: 'location',
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(
              _currentPosition!,
              15,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import '../core/location_manager.dart';

import '../models/geo_note.dart';

import '../services/firestore_service.dart';

import '../services/geofence_service.dart';

import '../services/notification_service.dart';

import '../widgets/note_dialog.dart';

import '../widgets/user_profile.dart';

class MapScreen
    extends StatefulWidget {

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState
    extends State<MapScreen> {

  final MapController _mapController =
      MapController();

  final FirestoreService
      _firestoreService =
      FirestoreService();

  final List<GeoNote> _notes = [];

  LatLng? _currentPosition;

  @override
  void initState() {

    super.initState();

    _initialize();
  }

  /// Inicializar app
  Future<void> _initialize() async {

    try {

      await LocationManager
          .requestPermission();

      final position =
          await LocationManager
              .getCurrentLocation();

      _listenLocation();

      setState(() {

        _currentPosition = LatLng(
          position.latitude,
          position.longitude,
        );
      });

      await _loadNotes();

    } catch (e) {

      debugPrint(
          'ERROR INIT: $e');
    }
  }

  /// Escuchar ubicación
  void _listenLocation() {

    LocationManager
        .getLocationStream()
        .listen(

      (position) {

        if (!mounted) return;

        setState(() {

          _currentPosition = LatLng(

            position.latitude,

            position.longitude,
          );
        });

        final activated =
            GeofenceService
                .evaluateGeofences(

          position.latitude,

          position.longitude,

          _notes,
        );

        for (var note in activated) {

          NotificationService
              .showAlert(

            context,

            note.message,
          );
        }
      },
    );
  }

  /// Cargar notas
  Future<void> _loadNotes() async {

    final loadedNotes =
        await _firestoreService
            .loadNotes();

    setState(() {

      _notes.clear();

      _notes.addAll(
          loadedNotes);
    });
  }

  /// Agregar nota
  Future<void> _addNote(
      LatLng position) async {

    final message =
        await NoteDialog.show(
            context);

    if (message == null) return;

    final note = GeoNote(

      lat: position.latitude,

      lng: position.longitude,

      message: message,
    );

    await _firestoreService
        .saveNote(note);

    await _loadNotes();
  }

  /// Eliminar nota
  Future<void> _deleteNote(
      int index) async {

    final note = _notes[index];

    if (note.id == null) return;

    await _firestoreService
        .deleteNote(note.id!);

    setState(() {

      _notes.removeAt(index);
    });
  }

  /// Dialogo información
  void _showNoteDialog(
      int index) {

    final note = _notes[index];

    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title:
            Text(note.message),

        content: Text(

          'Lat: ${note.lat}\n'
          'Lng: ${note.lng}',
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                  context);
            },

            child:
                const Text("Cerrar"),
          ),

          TextButton(

            onPressed: () async {

              Navigator.pop(
                  context);

              await _deleteNote(
                  index);
            },

            child:
                const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  /// Crear marcadores
  List<Marker> _buildMarkers() {

    return [

      ..._notes
          .asMap()
          .entries
          .map((entry) {

        final index = entry.key;

        final note = entry.value;

        return Marker(

          point: LatLng(
            note.lat,
            note.lng,
          ),

          width: 50,
          height: 50,

          child: GestureDetector(

            onTap: () {

              _showNoteDialog(
                  index);
            },

            child: const Icon(

              Icons.location_on,

              color: Colors.red,

              size: 40,
            ),
          ),
        );
      }),

      if (_currentPosition != null)

        Marker(

          point: _currentPosition!,

          width: 50,
          height: 50,

          child: const Icon(

            Icons.my_location,

            color: Colors.blue,

            size: 40,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    if (_currentPosition == null) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      drawer:
          const UserProfile(),

      appBar: AppBar(

        title:
            const Text(
                "Geo Messenger"),
      ),

      body: FlutterMap(

        mapController:
            _mapController,

        options: MapOptions(

          initialCenter:
              _currentPosition!,

          initialZoom: 15,

          onTap:
              (tapPosition, point) {

            _addNote(point);
          },
        ),

        children: [

          TileLayer(

            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

            userAgentPackageName:
                'com.example.geo_messenger',
          ),

          MarkerLayer(

            markers:
                _buildMarkers(),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          if (_currentPosition != null) {

            _mapController.move(

              _currentPosition!,

              15,
            );
          }
        },

        child:
            const Icon(
                Icons.my_location),
      ),
    );
  }
}