import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'Maps_Livreur.dart';

class LivreurHomePage extends StatelessWidget {
  const LivreurHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final livreurId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("👨‍✈️ Interface Livreur"),
        backgroundColor: const Color(0xffB81736),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("livreurId", isEqualTo: livreurId)
            .where("livraisonStatut", isNotEqualTo: "livrée")
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("📦 Aucune livraison assignée"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Commande : ${doc.id}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text("👤 Client : ${data['clientNom']}"),
                      Text("📞 Téléphone : ${data['clientTelephone']}"),
                      const SizedBox(height: 6),

                      Text(
                        "📍 Adresse : ${data['adresseLivraison']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text("Carte"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapsLivreur(
                                    adresseClient:
                                    data['adresseLivraison'],
                                    nomClient: data['clientNom'],
                                    telephoneClient:
                                    data['clientTelephone'],
                                  ),
                                ),
                              );
                            },
                          ),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Livrée"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("payments")
                                  .doc(doc.id)
                                  .update({
                                "livraisonStatut": "livrée",
                                "dateLivraison":
                                FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("✅ Livraison confirmée"),
                                ),
                              );
                            },
                          ),
                        ],
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
