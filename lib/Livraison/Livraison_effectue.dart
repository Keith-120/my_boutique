import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LivreurLivraisonPage extends StatelessWidget {
  const LivreurLivraisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📦 Mes livraisons"),
        backgroundColor: const Color(0xffB81736),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("livreurId", isEqualTo: user!.uid)
            .where("livraisonStatut", isEqualTo: "en cours")
            .snapshots(),

        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucune livraison en cours"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

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
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text("👤 Client : ${data['clientNom']}"),
                      Text("📞 Téléphone : ${data['clientTelephone']}"),
                      Text("📍 Adresse : ${data['adresseLivraison']}"),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Livraison effectuée"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                        onPressed: () =>
                            _confirmerLivraison(context, doc.id),
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


  Future<void> _confirmerLivraison(
      BuildContext context,
      String commandeId,
      ) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
            "Confirmer que la livraison a été effectuée ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection("payments")
        .doc(commandeId)
        .update({
      "livraisonStatut": "livree",
      "dateLivraison": FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(msg: "✅ Livraison confirmée");

    Navigator.pop(context);
  }
}
