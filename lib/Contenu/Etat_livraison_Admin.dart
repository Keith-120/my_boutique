import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EtatLivraisonsPage extends StatelessWidget {
  const EtatLivraisonsPage({super.key});

  String formatDate(Timestamp ts) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📦 État des livraisons")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup("cart")
            .where("statut", isEqualTo: "ok")
            .orderBy("dateLivraison", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: Text("Aucun Produits Livré "));
          }

          // 🔹 Si aucune livraison n'est effectuée
          if (snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune livraison effectuée",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              final d = snap.data!.docs[index];
              final data = d.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['title'] ?? "Produit"),
                  subtitle: Text(
                    "Commande : ${data['numeroAchat']}\nLivré le : ${formatDate(data['dateLivraison'])}",
                  ),
                  trailing:
                  const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
