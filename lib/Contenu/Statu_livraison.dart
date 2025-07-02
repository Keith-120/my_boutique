import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Statut_livraison_client.dart';

// admin_page.dart
class AdminPage extends StatefulWidget
{
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<List<Map<String, dynamic>>> fetchAllCartItems() async
  {
    List<Map<String, dynamic>> items = [];
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['nom'] ?? 'Nom inconnu';

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

        items.add({
          'title': data['title'] ?? 'Sans titre',
          'price': data['price'] ?? 0,
          'Quantite': data['Quantite'] ?? 0,
          'isChecked': data['isChecked'],
          'userName': userName,
        });
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit trouvé.'));
          }

          var produits = snapshot.data!;

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                    ),
                  ),
                  padding: EdgeInsets.only(top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Liste des Produits \n Livre et non Livre !",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: Text(
                              "Statut de Livraison Des Produits",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(
                            height: 400,
                            child: ListView.builder(
                              itemCount: produits.length,
                              itemBuilder: (context, index) {
                                var produit = produits[index];
                                return ListTile(
                                  leading: Icon(
                                    produit['isChecked'] ? Icons.check_circle : Icons.cancel,
                                    color: produit['isChecked'] ? Colors.green : Colors.red,
                                  ),
                                  title: Text('${produit['title']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${produit['price']} FCFA'),
                                      Text('Client: ${produit['userName']}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text('Quantite:${produit['Quantite']}'),
                                    ],
                                  ),
                                  trailing: Text(
                                    produit['isChecked'] ? 'Livré' : 'Non livré',
                                    style: TextStyle(
                                      color: produit['isChecked'] ? Colors.green : Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

// client_page.dart à créer de la même façon avec fetchCartSummary() comme expliqué dans la réponse précédente
