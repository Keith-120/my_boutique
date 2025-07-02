import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchCartSummary() async {
    List<Map<String, dynamic>> items = [];

    if (user == null) return items;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      var rawData = doc.data();

      if (rawData == null) continue;

      Map<String, dynamic> data;
      try {
        data = rawData as Map<String, dynamic>;
      } catch (e) {
        print("Erreur de cast des données : $e");
        continue;
      }

      if (!data.containsKey('isChecked')) {
        await doc.reference.update({'isChecked': false});
        data['isChecked'] = false;
      }

      // ✅ Ajouter la date de livraison si livrée mais pas encore enregistrée
      if (data['isChecked'] == true && !data.containsKey('deliveryDate')) {
        Timestamp now = Timestamp.now();
        await doc.reference.update({'deliveryDate': now});
        data['deliveryDate'] = now;
      }

      items.add({
        'title': data['title'] ?? 'Sans titre',
        'price': data['price'] ?? 0,
        'Quantite': data['Quantite'] ?? 0,
        'isChecked': data['isChecked'] ?? false,
        'deliveryDate': data['deliveryDate'],
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCartSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun produit trouvé"));
          }

          var produits = snapshot.data!;
          var livres = produits.where((p) => p['isChecked'] == true).toList();
          var nonLivres = produits.where((p) => p['isChecked'] == false).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Section("Produits Livrés", livres, Colors.green),
                Section("Produits Non Livrés", nonLivres, Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color color;

  Section(this.title, this.items, this.color);

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Date inconnue";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var produit = items[index];
            return ListTile(
              leading: Icon(Icons.circle, color: color),
              title: Text(produit['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${produit['price']} FCFA"),
                  Text('Quantité: ${produit['Quantite'] ?? 1}'),
                  if (title.contains("Livrés") && produit['deliveryDate'] != null)
                    Text("Livré le : ${formatDate(produit['deliveryDate'])}"),
                ],
              ),
              trailing: Text(
                title.contains("Livrés") ? "Livré" : "Non livré",
                style: TextStyle(color: color),
              ),
            );
          },
        ),
      ],
    );
  }
}

