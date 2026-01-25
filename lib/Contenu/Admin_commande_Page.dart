/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Etat_livraison_Admin.dart';


class AdminCommandesPage extends StatelessWidget {
  const AdminCommandesPage({super.key});

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Commandes"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),

      body: _buildPaidOrders(),

      // 🔽 BOUTON ÉTAT DE LIVRAISON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EtatLivraisonsPage(),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "📦 État des livraisons",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 1 — Paiements PayPal validés uniquement
  Widget _buildPaidOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("payments")
          .where("status", isEqualTo: "COMPLETED")
          .snapshots(),
      builder: (context, paySnap) {
        if (!paySnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paySnap.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune commande payée."));
        }

        final paidOrderIds =
        paySnap.data!.docs.map((e) => e.id).toSet();

        return _buildOrdersFromCart(paidOrderIds);
      },
    );
  }

  // 🔥 2 — Commandes liées aux paiements
  Widget _buildOrdersFromCart(Set<String> paidOrderIds) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup("cart").snapshots(),
      builder: (context, cartSnap) {
        if (!cartSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, List<QueryDocumentSnapshot>> grouped = {};

        for (var doc in cartSnap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final numero = data['numeroAchat'];

          if (!paidOrderIds.contains(numero)) continue;

          grouped.putIfAbsent(numero, () => []);
          grouped[numero]!.add(doc);
        }

        if (grouped.isEmpty) {
          return const Center(child: Text("Aucune commande valide."));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((e) {
            return _buildCommandeCard(context, e.key, e.value);
          }).toList(),
        );
      },
    );
  }

  // 🧾 CARTE COMMANDE
  Widget _buildCommandeCard(
      BuildContext context,
      String numeroAchat,
      List<QueryDocumentSnapshot> items,
      ) {
    final bool estLivree =
    items.every((e) => (e.data() as Map)['statut'] == "ok");

    final total = items.fold<double>(0, (sum, doc) {
      final d = doc.data() as Map<String, dynamic>;
      return sum + (d['montantTotal'] ?? 0).toDouble();
    });

    final userId = (items.first.data() as Map)['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future:
      FirebaseFirestore.instance.collection("users").doc(userId).get(),
      builder: (context, snap) {
        final user = snap.data?.data() as Map?;
        final nom = user?['nom'] ?? "Client";
        final tel = user?['phone'] ?? "N/A";

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Commande : $numeroAchat",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("👤 Client : $nom"),
                Text("📞 Téléphone : $tel"),
                const SizedBox(height: 6),
                Text("💰 Total : ${total.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: estLivree ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estLivree ? "Livrée" : "En attente",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    if (!estLivree)
                      ElevatedButton(
                        onPressed: () =>
                            _confirmerLivraison(context, items),
                        child: const Text("Confirmer"),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔐 CONFIRMATION LIVRAISON
  Future<void> _confirmerLivraison(
      BuildContext context,
      List<QueryDocumentSnapshot> items,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content:
        const Text("Confirmer que cette commande a été livrée ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmer")),
        ],
      ),
    );

    if (confirm != true) return;

    for (var doc in items) {
      await doc.reference.update({
        "statut": "ok",
        "dateLivraison": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Livraison confirmée"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Etat_livraison_Admin.dart';

class AdminCommandesPage extends StatelessWidget {
  const AdminCommandesPage({super.key});

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Commandes"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),

      body: _buildPaidOrders(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EtatLivraisonsPage(),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "📦 État des livraisons",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPaidOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("payments")
          .where("status", isEqualTo: "COMPLETED")
          .snapshots(),
      builder: (context, paySnap) {
        if (!paySnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paySnap.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune commande payée."));
        }


        final Map<String, Map<String, String>> commandesInfos = {};

        for (var doc in paySnap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          commandesInfos[doc.id] = {
            "nom": data["nomClient"] ?? "Client",
            "telephone": data["telephoneClient"] ?? "N/A",
            "adresse": data["adresseLivraison"] ?? "Adresse non fournie",
          };
        }

        return _buildOrdersFromCart(commandesInfos);
      },
    );
  }


  Widget _buildOrdersFromCart(
      Map<String, Map<String, String>> commandesInfos) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup("cart").snapshots(),
      builder: (context, cartSnap) {
        if (!cartSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, List<QueryDocumentSnapshot>> grouped = {};

        for (var doc in cartSnap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final numero = data['numeroAchat'];

          if (!commandesInfos.containsKey(numero)) continue;

          grouped.putIfAbsent(numero, () => []);
          grouped[numero]!.add(doc);
        }

        if (grouped.isEmpty) {
          return const Center(child: Text("Aucune commande valide."));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            return _buildCommandeCard(
              context,
              entry.key,
              entry.value,
              commandesInfos[entry.key]!,
            );
          }).toList(),
        );
      },
    );
  }


  Widget _buildCommandeCard(
      BuildContext context,
      String numeroAchat,
      List<QueryDocumentSnapshot> items,
      Map<String, String> infosClient,
      ) {
    final bool estLivree =
    items.every((e) => (e.data() as Map)['statut'] == "ok");

    final total = items.fold<double>(0, (sum, doc) {
      final d = doc.data() as Map<String, dynamic>;
      return sum + (d['montantTotal'] ?? 0).toDouble();
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Commande : $numeroAchat",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 10),
            Text("👤 Client : ${infosClient['nom']}"),
            Text("📞 Téléphone : ${infosClient['telephone']}"),

            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    infosClient['adresse']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              "💰 Total : ${total.toStringAsFixed(0)} FCFA",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: estLivree ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estLivree ? "Livrée" : "En attente",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                if (!estLivree)
                  ElevatedButton(
                    onPressed: () =>
                        _confirmerLivraison(context, items),
                    child: const Text("Confirmer"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔐 CONFIRMATION LIVRAISON
  Future<void> _confirmerLivraison(
      BuildContext context,
      List<QueryDocumentSnapshot> items,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content:
        const Text("Confirmer que cette commande a été livrée ?"),
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

    for (var doc in items) {
      await doc.reference.update({
        "statut": "ok",
        "dateLivraison": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Livraison confirmée"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
