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
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// LOGIN GOOGLE
  Future<User?> signInWithGoogle() async {

    try {

      /// WEB
      if (kIsWeb) {

        GoogleAuthProvider provider =
            GoogleAuthProvider();

        final userCredential =
            await _auth.signInWithPopup(
                provider);

        return userCredential.user;
      }

      /// ANDROID
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication
          googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(

        accessToken:
            googleAuth.accessToken,

        idToken:
            googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(
              credential);

      return userCredential.user;

    } catch (e) {

      debugPrint(
          'ERROR LOGIN GOOGLE: $e');

      return null;
    }
  }

  /// CERRAR SESIÓN
  Future<void> signOut() async {

    await GoogleSignIn().signOut();

    await _auth.signOut();
  }
}