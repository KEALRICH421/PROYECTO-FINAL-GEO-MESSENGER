import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/geo_note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveNote(GeoNote note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add(note.toMap());
  }

  Future<List<GeoNote>> loadNotes() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot =
        await _db.collection('users').doc(user.uid).collection('notes').get();
    return snapshot.docs
        .map((doc) => GeoNote.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<GeoNote>> noteStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GeoNote.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteNote(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .delete();
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .update(data);
  }
}
