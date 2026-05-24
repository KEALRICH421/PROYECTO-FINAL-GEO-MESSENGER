import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geo_messenger/Screens/login_screen.dart';
import 'Screens/map_screen.dart';

const FirebaseOptions webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCX2CShAmzwAOt20m4ubpZMtK0j3N4Z7zw',
  authDomain: 'geomessenger-7fe16.firebaseapp.com',
  projectId: 'geomessenger-7fe16',
  storageBucket: 'geomessenger-7fe16.firebasestorage.app',
  messagingSenderId: '97694840925',
  appId: '1:97694840925:web:228384ae9955520bde35b4',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: webFirebaseOptions);
    } else {
      await Firebase.initializeApp();
    }
    runApp(const GeoMessengerApp());
  } catch (error, stackTrace) {
    runApp(FirebaseErrorApp(error, stackTrace));
  }
}

/// Punto de entrada principal de la aplicación.
/// Se define la configuración global de la app.
class GeoMessengerApp extends StatelessWidget {
  const GeoMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

/// Muestra un error legible si la inicialización de Firebase falla.
class FirebaseErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const FirebaseErrorApp(this.error, this.stackTrace, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Error de Firebase')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No se pudo inicializar Firebase en web.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reemplaza los valores de FirebaseOptions en lib/main.dart con los datos de tu app web desde Firebase Console.',
              ),
              const SizedBox(height: 16),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';

import 'screens/map_screen.dart';

const FirebaseOptions
    webFirebaseOptions =
    FirebaseOptions(

  apiKey:
      'TU_API_KEY',

  authDomain:
      'TU_AUTH_DOMAIN',

  projectId:
      'TU_PROJECT_ID',

  storageBucket:
      'TU_STORAGE_BUCKET',

  messagingSenderId:
      'TU_MESSAGING_SENDER_ID',

  appId:
      'TU_APP_ID',
);

Future<void> main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  if (kIsWeb) {

    await Firebase.initializeApp(

      options:
          webFirebaseOptions,
    );

  } else {

    await Firebase.initializeApp();
  }

  runApp(
      const GeoMessengerApp());
}

class GeoMessengerApp
    extends StatelessWidget {

  const GeoMessengerApp(
      {super.key});

  @override
  Widget build(
      BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title:
          'Geo Messenger',

      theme: ThemeData(

        primarySwatch:
            Colors.deepPurple,
      ),

      home:
          StreamBuilder<User?>(

        stream:
            FirebaseAuth.instance
                .authStateChanges(),

        builder:
            (context, snapshot) {

          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {

            return const Scaffold(

              body: Center(

                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {

            return const MapScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}