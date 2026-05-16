import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Iniciar sesión con Google (WEB + FIREBASE CORRECTO)
  Future<User?> signInWithGoogle() async {
    try {
      print("Iniciando Google Sign-In...");

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      print("Login exitoso: ${userCredential.user?.email}");

      return userCredential.user;
    } catch (e) {
      print("Error login: $e");
      print("Stack trace: ${StackTrace.current}");

      return null;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}