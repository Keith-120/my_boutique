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


      if (data['isChecked'] == true && !data.containsKey('deliveryDate')) {
        Timestamp now = Timestamp.now();
        await doc.reference.update({'deliveryDate': now});
        data['deliveryDate'] = now;
      }

      items.add({
        'title': data['title'] ?? 'Sans titre',
        'price': data['price'] ?? 0,
        'Quantite': data['Quantite'] ?? 1,
        'isChecked': data['isChecked'] ?? false,
        'deliveryDate': data['deliveryDate'],
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🛒 Mes Commandes"),
        centerTitle: true,
      ),
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


          produits.sort((a, b) {
            var dateA = a['deliveryDate'] as Timestamp?;
            var dateB = b['deliveryDate'] as Timestamp?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1; // Non livré après livré
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // plus récent d'abord
          });

          var livres = produits.where((p) => p['isChecked'] == true).toList();
          var nonLivres = produits.where((p) => p['isChecked'] == false).toList();

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "📦 Suivi de mes commandes",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: ListView(
                      children: [
                        Section("Produits Livrés", livres, Colors.green),
                        Section("Produits Non Livrés", nonLivres, Colors.red),
                      ],
                    ),
                  ),
                ),
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

  String formatDate(Timestamp? timestamp, bool isChecked) {
    if (!isChecked) return "⏳ En attente";
    if (timestamp == null) return "Date inconnue";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Aucun $title",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        ...items.map((produit) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: color),
              title: Text(produit['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${produit['price']} FCFA"),
                  Text('Quantité: ${produit['Quantite'] ?? 1}'),
                  Text("📅 ${formatDate(produit['deliveryDate'], produit['isChecked'])}"),
                ],
              ),
              trailing: Text(
                produit['isChecked'] ? "✅ Livré" : "❌ Non livré",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
