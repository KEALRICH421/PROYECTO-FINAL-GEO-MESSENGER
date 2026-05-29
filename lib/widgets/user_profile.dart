import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/geo_note.dart';
import '../Services/auth_service.dart';

class UserProfile extends StatelessWidget {
  final List<GeoNote> notes;
  final void Function(GeoNote note) onNoteSelected;
  final void Function(GeoNote note) onNoteEdit;

  const UserProfile({
    super.key,
    required this.notes,
    required this.onNoteSelected,
    required this.onNoteEdit,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    user.photoURL != null && user.photoURL!.isNotEmpty
                        ? NetworkImage(user.photoURL!)
                        : null,
                child: user.photoURL == null || user.photoURL!.isEmpty
                    ? Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              accountName: Text(user.displayName ?? 'Usuario'),
              accountEmail: Text(user.email ?? ''),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const ListTile(
                    leading: Icon(Icons.note),
                    title: Text('Mis notas'),
                  ),
                  if (notes.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No tienes notas guardadas todavía.'),
                    )
                  else
                    ...notes.map(
                      (note) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(note.message),
                        subtitle: Text(
                          'Lat: ${note.lat.toStringAsFixed(5)}, Lng: ${note.lng.toStringAsFixed(5)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onNoteEdit(note);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          onNoteSelected(note);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await AuthService().signOut();
                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
