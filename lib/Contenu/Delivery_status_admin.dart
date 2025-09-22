import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  Stream<Map<String, List<Map<String, dynamic>>>> fetchAllCartItems() async* {
    Map<String, List<Map<String, dynamic>>> groupedItems = {};

    QuerySnapshot usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['nom'] ?? 'Nom inconnu';
      final userEmail = userData['email'] ?? 'email_inconnu@example.com';
      final userPhone = userData['phone'] ?? 'Téléphone inconnu'; // ✅ Correction

      final userIdentifier = '$userName | $userEmail | $userPhone';

      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      for (var cartDoc in cartSnapshot.docs) {
        Map<String, dynamic> data = cartDoc.data() as Map<String, dynamic>;


        if (!data.containsKey('isChecked')) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('cart')
              .doc(cartDoc.id)
              .update({'isChecked': false});
          data['isChecked'] = false;
        }

        if (!groupedItems.containsKey(userIdentifier)) {
          groupedItems[userIdentifier] = [];
        }

        groupedItems[userIdentifier]!.add({
          'title': data['title'] ?? 'Sans titre',
          'price': data['price'] ?? 0,
          'Quantite': data['Quantite'] ?? 1,
          'isChecked': data['isChecked'],
          'deliveryDate': data['deliveryDate'], // 🔹 Date de livraison
        });
      }
    }

    yield groupedItems;
  }


  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Date inconnue";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📦 Suivi des livraisons"),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: fetchAllCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit trouvé.'));
          }

          final groupedProduits = snapshot.data!;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Liste des commandes par client",
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
                        children: groupedProduits.entries.map((entry) {
                          final userIdentifier = entry.key;
                          final commandes = entry.value;


                          commandes.sort((a, b) {
                            if (a['isChecked'] && b['isChecked']) {
                              Timestamp? dateA = a['deliveryDate'];
                              Timestamp? dateB = b['deliveryDate'];
                              if (dateA != null && dateB != null) {
                                return dateB.compareTo(dateA); // plus récent en premier
                              }
                            }
                            if (a['isChecked'] && !b['isChecked']) return -1;
                            if (!a['isChecked'] && b['isChecked']) return 1;
                            return 0;
                          });

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            child: ExpansionTile(
                              leading: Icon(Icons.person, color: Color(0xffB81736)),
                              title: Text(
                                userIdentifier,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              children: commandes.map((produit) {
                                Timestamp? deliveryDate = produit['deliveryDate'];

                                return ListTile(
                                  leading: Icon(
                                    produit['isChecked']
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: produit['isChecked']
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text('${produit['title']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${produit['price']} FCFA'),
                                      Text('Quantité : ${produit['Quantite']}'),
                                      if (produit['isChecked'] && deliveryDate != null)
                                        Text(
                                          "📅 Livré le : ${formatDate(deliveryDate)}",
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.black54),
                                        ),
                                    ],
                                  ),
                                  trailing: Text(
                                    produit['isChecked'] ? '✅ Livré' : '❌ Non livré',
                                    style: TextStyle(
                                      color: produit['isChecked']
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
