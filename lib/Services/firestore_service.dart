import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/geo_note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// GUARDAR NOTA
  Future<void> saveNote(GeoNote note) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _db.collection("users").doc(user.uid).collection("notes").add({
      "lat": note.lat,
      "lng": note.lng,
      "message": note.message,
      "radius": note.radius,
      "triggered": note.triggered,
    });
  }

  /// LEER NOTAS
  Future<List<GeoNote>> loadNotes() async {
    final user = _auth.currentUser;

    if (user == null) return [];

    final snapshot =
        await _db.collection("users").doc(user.uid).collection("notes").get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return GeoNote(
        lat: data['lat'],
        lng: data['lng'],
        message: data['message'],
        radius: data['radius'],
        triggered: data['triggered'],
      );
    }).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/geo_note.dart';

class FirestoreService {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// GUARDAR NOTA
  Future<void> saveNote(
      GeoNote note) async {

    final user = _auth.currentUser;

    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("notes")
        .add(note.toMap());
  }

  /// CARGAR NOTAS
  Future<List<GeoNote>> loadNotes() async {

    final user = _auth.currentUser;

    if (user == null) return [];

    final snapshot =
        await _db
            .collection("users")
            .doc(user.uid)
            .collection("notes")
            .get();

    return snapshot.docs.map((doc) {

      return GeoNote.fromFirestore(
        doc.data(),
        doc.id,
      );

    }).toList();
  }

  /// ELIMINAR NOTA
  Future<void> deleteNote(
      String id) async {

    final user = _auth.currentUser;

    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("notes")
        .doc(id)
        .delete();
  }
}