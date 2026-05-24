import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile extends StatelessWidget {

  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return Drawer(

      child: Column(

        children: [

          UserAccountsDrawerHeader(

            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  NetworkImage(user.photoURL ?? ""),
            ),

            accountName:
                Text(user.displayName ?? "Usuario"),

            accountEmail:
                Text(user.email ?? ""),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

/// Drawer perfil usuario
class UserProfile
    extends StatelessWidget {

  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return Drawer(

      child: Column(

        children: [

          UserAccountsDrawerHeader(

            currentAccountPicture:

                CircleAvatar(

              backgroundImage:
                  NetworkImage(
                user.photoURL ?? "",
              ),
            ),

            accountName: Text(
              user.displayName ??
                  "Usuario",
            ),

            accountEmail: Text(
              user.email ?? "",
            ),
          ),

          ListTile(

            leading:
                const Icon(Icons.logout),

            title:
                const Text("Cerrar sesión"),

            onTap: () async {

              await AuthService()
                  .signOut();
            },
          ),
        ],
      ),
    );
  }
}