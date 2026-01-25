import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Livreur_Home.dart';

class LivreurGate extends StatelessWidget {
  const LivreurGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Non connecté")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>?;

        if (data == null || data['role'] != 'livreur') {
          return const Scaffold(
            body: Center(
              child: Text(
                "🚫 Accès refusé\nVous n'êtes pas livreur",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return const LivreurHomePage();
      },
    );
  }
}
