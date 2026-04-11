import 'package:flutter/material.dart';

/// Widget reutilizable para crear notas.
/// Mejora la organización del código.
class NoteDialog {
  static Future<String?> show(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva Nota"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Escribe tu recordatorio",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
