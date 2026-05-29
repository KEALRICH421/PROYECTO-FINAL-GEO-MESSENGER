import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Core/location_manager.dart';
import '../Models/geo_note.dart';
import '../Services/firestore_service.dart';
import '../Services/geofence_service.dart';
import '../Services/notification_service.dart';
import '../widgets/note_dialog.dart';
import '../widgets/user_profile.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final FirestoreService _firestoreService = FirestoreService();
  final List<GeoNote> _notes = [];
  LatLng? _currentPosition;
  LatLng? _lastTapPosition;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription<List<GeoNote>>? _notesSubscription;

  Future<void> _initialize() async {
    try {
      await LocationManager.requestPermission();
      _listenLocation();
      _listenNotes();

      final position = await LocationManager.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('ERROR INIT: $e');
    }
  }

  void _listenLocation() {
    LocationManager.getLocationStream().listen(
      (position) {
        if (!mounted) return;

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        final activated = GeofenceService.evaluateGeofences(
          position.latitude,
          position.longitude,
          _notes,
        );

        for (var note in activated) {
          NotificationService.showAlert(context, note.message);
        }
      },
      onError: (e) {
        debugPrint('LOCATION STREAM ERROR: $e');
      },
    );
  }

  void _listenNotes() {
    _notesSubscription = _firestoreService.noteStream().listen(
      (loadedNotes) {
        if (!mounted) return;
        setState(() {
          _notes
            ..clear()
            ..addAll(loadedNotes);
        });
      },
      onError: (e) {
        debugPrint('ERROR NOTE STREAM: $e');
      },
    );
  }

  Future<void> _addNote(LatLng position) async {
    final currentContext = context;
    final message = await NoteDialog.show(currentContext);
    if (message == null || message.trim().isEmpty) {
      return;
    }

    final note = GeoNote(
      lat: position.latitude,
      lng: position.longitude,
      message: message.trim(),
    );

    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _firestoreService.saveNote(note);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Nota guardada correctamente.')),
      );
    } catch (e) {
      debugPrint('ERROR SAVE NOTE: $e');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al guardar nota: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote(int index) async {
    final note = _notes[index];
    if (note.id == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _firestoreService.deleteNote(note.id!);
      if (!mounted) return;

      setState(() {
        _notes.removeAt(index);
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Nota eliminada.')),
      );
    } catch (e) {
      debugPrint('ERROR DELETE NOTE: $e');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar nota: $e')),
        );
      }
    }
  }

  Future<void> _editNote(GeoNote note) async {
    if (note.id == null) return;

    final currentContext = context;
    final message = await NoteDialog.show(
      currentContext,
      initialText: note.message,
      title: 'Editar Nota',
      saveButton: 'Actualizar',
    );

    if (message == null || message.trim().isEmpty) {
      return;
    }

    try {
      await _firestoreService.updateNote(note.id!, {'message': message.trim()});
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Nota actualizada.')),
      );
    } catch (e) {
      debugPrint('ERROR UPDATE NOTE: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Error al actualizar nota: $e')),
        );
      }
    }
  }

  Future<void> _showNoteDialog(int index) async {
    final note = _notes[index];
    final currentContext = context;

    final action = await showDialog<String?>(
      context: currentContext,
      builder: (_) => AlertDialog(
        title: Text(note.message),
        content: Text('Lat: ${note.lat}\nLng: ${note.lng}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(currentContext, 'close'),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(currentContext, 'edit'),
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(currentContext, 'delete'),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (action == 'edit') {
      await _editNote(note);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        // ignore: use_build_context_synchronously
        context: currentContext,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Seguro que quieres eliminar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(currentContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(currentContext, true),
              child: const Text('Sí, eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _deleteNote(index);
      }
    }
  }

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
      ),
      drawer: UserProfile(
        notes: _notes,
        onNoteSelected: (note) {
          _mapController.move(LatLng(note.lat, note.lng), 17);
          setState(() {
            _lastTapPosition = LatLng(note.lat, note.lng);
          });
        },
        onNoteEdit: (note) async {
          await _editNote(note);
        },
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) {
                setState(() {
                  _lastTapPosition = point;
                });
                _addNote(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.geomessenger',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton.icon(
            onPressed: (_lastTapPosition ?? _currentPosition) == null
                ? null
                : () => _addNote(_lastTapPosition ?? _currentPosition!),
            icon: const Icon(Icons.add_location),
            label: const Text('Agregar nota en última ubicación'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'location',
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
