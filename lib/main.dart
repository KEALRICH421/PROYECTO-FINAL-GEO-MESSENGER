import 'package:flutter/material.dart';
import 'Screens/map_screen.dart';

void main() {
  runApp(const GeoMessengerApp());
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
      home: const MapScreen(),
    );
  }
}