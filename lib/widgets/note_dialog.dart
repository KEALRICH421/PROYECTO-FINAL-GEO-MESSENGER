import 'package:flutter/material.dart';

class NoteDialog {
  static Future<String?> show(
    BuildContext context, {
    String? initialText,
    String title = 'Nueva Nota',
    String saveButton = 'Guardar',
  }) async {
    final controller = TextEditingController(text: initialText ?? '');

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe tu recordatorio',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: Text(saveButton),
          ),
        ],
      ),
    );
  }
}
