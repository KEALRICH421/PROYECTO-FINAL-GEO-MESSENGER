import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('GoogleSignIn returned null after account selection.');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e, stackTrace) {
      debugPrint('ERROR LOGIN GOOGLE: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
