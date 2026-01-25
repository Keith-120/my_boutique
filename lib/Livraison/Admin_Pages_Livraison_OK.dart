import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminLivraisonsEffectueesPage extends StatelessWidget {
  const AdminLivraisonsEffectueesPage({super.key});

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📦 Livraisons effectuées"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("livraisonStatut", isEqualTo: "livree")
            .orderBy("dateLivraison", descending: true)
            .snapshots(),

        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune livraison effectuée",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['dateLivraison'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Commande : ${doc.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text("👤 Client : ${data['clientNom']}"),
                      Text("📞 Téléphone : ${data['clientTelephone']}"),
                      Text("📍 Adresse : ${data['adresseLivraison']}"),
                      const SizedBox(height: 6),

                      Text(
                        "👨‍✈️ Livreur : ${data['livreurNom']} (${data['livreurTelephone']})",
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Livraison effectuée ✅",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (date != null)
                        Text(
                          "🕒 Livrée le : ${DateFormat('dd/MM/yyyy à HH:mm').format(date)}",
                          style: const TextStyle(fontSize: 13),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
