import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _webClientId =
      '697148975888-5kv4rjeflma4rd2jaa24f92pgtecdu7v.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      kIsWeb ? GoogleSignIn(clientId: _webClientId) : GoogleSignIn();

  /// Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      print("Iniciando Google Sign-In...");
      if (kIsWeb) {
        print("Usando clientId web: $_webClientId");
      }

      // Abrir selector de cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In cancelado por el usuario");
        return null;
      }

      print("Usuario de Google seleccionado: ${googleUser.email}");

      // Obtener credenciales
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Autenticación de Google obtenida");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar en Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      print("Login exitoso: ${userCredential.user?.email}");
      return userCredential.user;
    } catch (e) {
      print("Error login: $e");
      print("Stack trace: ${StackTrace.current}");

      if (e.toString().contains("ClientID not set")) {
        print("❌ Error: Google Sign-In no está configurado");
        print(
            "Solución: configura el Client ID en web/index.html o con GoogleSignIn(clientId: ...)");
      }

      if (e.toString().contains("invalid_client")) {
        print("❌ Error: invalid_client");
        print(
            "Solución: verifica que este client ID sea un OAuth 2.0 Client ID de tipo web");
        print(
            "y que tengas autorizado el origen http://localhost:53943 en Google Cloud Console");
      }
      return null;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
