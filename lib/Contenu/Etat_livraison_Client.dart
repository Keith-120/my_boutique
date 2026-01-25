import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MesLivraisonsPage extends StatelessWidget {
  const MesLivraisonsPage({super.key});

  String formatDate(Timestamp ts) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Veuillez vous connecter pour voir vos livraisons.")),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("📦 Mes livraisons"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "⏳ Non livrés"),
              Tab(text: "✅ Livrés"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLivraisons(user.uid, false), // Non livrés
            _buildLivraisons(user.uid, true),  // Livrés
          ],
        ),
      ),
    );
  }

  Widget _buildLivraisons(String userId, bool isDelivered) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup("cart")
          .where("userId", isEqualTo: userId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final items = snap.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return (data['statut'] == "ok") == isDelivered;
        }).toList();

        if (items.isEmpty) {
          return Center(
            child: Text(
              isDelivered ? "Aucune livraison effectuée." : "Aucun produit en attente.",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;
            final deliveredDate = data['dateLivraison'] as Timestamp?;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(data['title'] ?? "Produit"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Commande : ${data['numeroAchat']}"),
                    if (isDelivered && deliveredDate != null)
                      Text("Livré le : ${formatDate(deliveredDate)}"),
                  ],
                ),
                trailing: Icon(
                  isDelivered ? Icons.check_circle : Icons.pending,
                  color: isDelivered ? Colors.green : Colors.orange,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
