import 'package:flutter/material.dart';

/// Servicio de notificaciones.
/// Actualmente usa diálogos, pero puede escalar a notificaciones reales.
class NotificationService {
  /// Muestra una alerta en pantalla
  static void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📍 Recordatorio"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
