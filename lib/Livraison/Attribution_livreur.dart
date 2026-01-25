import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttributionLivreurPage extends StatelessWidget
{
  const AdminAttributionLivreurPage({super.key});

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚚 Attribution livreur"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("status", isEqualTo: "COMPLETED")
            .snapshots(),
        builder: (context, snap)
        {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucune commande payée"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final livreurAttribue = data['livreurId'] != null &&
                  data['livreurId'].toString().isNotEmpty;

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

                      Text("💰 Montant : ${data['amount']} USD"),
                      Text("📍 Adresse : ${data['adresseLivraison'] ?? '—'}"),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: livreurAttribue
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              livreurAttribue
                                  ? "Livreur attribué"
                                  : "Non attribuée",
                              style:
                              const TextStyle(color: Colors.white),
                            ),
                          ),

                          if (!livreurAttribue)
                            ElevatedButton(
                              onPressed: () => _attribuerLivreur(
                                context,
                                doc.id,
                              ),
                              child: const Text("Attribuer"),
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


  Future<void> _attribuerLivreur(
      BuildContext context,
      String commandeId,
      ) async {
    final livreursSnap = await FirebaseFirestore.instance
        .collection("livreurs")
        .where("disponible", isEqualTo: true)
        .get();

    if (livreursSnap.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun livreur disponible"),
        ),
      );
      return;
    }

    String? livreurIdSelectionne;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choisir un livreur"),
        content: DropdownButtonFormField<String>(
          items: livreursSnap.docs.map((doc) {
            final data = doc.data();
            return DropdownMenuItem(
              value: doc.id,
              child: Text(
                "${data['nom']} • ${data['telephone']}",
              ),
            );
          }).toList(),
          onChanged: (v) => livreurIdSelectionne = v,
          decoration:
          const InputDecoration(labelText: "Livreur"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (livreurIdSelectionne == null) return;

              final livreurDoc = await FirebaseFirestore.instance
                  .collection("livreurs")
                  .doc(livreurIdSelectionne)
                  .get();

              await FirebaseFirestore.instance
                  .collection("payments")
                  .doc(commandeId)
                  .update({
                "livreurId": livreurIdSelectionne,
                "livreurNom": livreurDoc['nom'],
                "livreurTelephone": livreurDoc['telephone'],
                "livraisonStatut": "en cours",
                "dateAttribution":
                FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Livreur attribué"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }
}
