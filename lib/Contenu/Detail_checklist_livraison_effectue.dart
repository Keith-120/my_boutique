import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartChecklistPage extends StatefulWidget {
  final String userId;

  const CartChecklistPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CartChecklistPageState createState() => _CartChecklistPageState();
}

class _CartChecklistPageState extends State<CartChecklistPage> {
  User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getCartStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .snapshots();
  }

  //  Nouvelle fonction pour gérer le changement de case
  Future<void> handleCheckChange(DocumentSnapshot produit, bool checked) async {
    await confirmDelivery(produit, checked);
  }

  Future<void> confirmDelivery(DocumentSnapshot produit, bool checked) async {
    final data = produit.data() as Map<String, dynamic>;

    print("Checkbox changée : $checked");
    print("Contenu produit : $data");

    final String? articleId = data['articleId'];
    final String? collectionName = data['collection'];
    final int quantity = data['Quantite'] is int
        ? data['Quantite']
        : int.tryParse(data['Quantite'].toString()) ?? 1;
    final bool stockUpdated = data['stockUpdated'] ?? false;

    if (articleId == null || articleId.isEmpty || collectionName == null || collectionName.isEmpty) {
      print("Erreur : articleId ou collectionName manquant.");
      return;
    }

    final productRef = FirebaseFirestore.instance.collection(collectionName).doc(articleId);
    final productSnapshot = await productRef.get();

    if (!productSnapshot.exists) {
      print("Erreur : article non trouvé dans la collection.");
      return;
    }

    final productData = productSnapshot.data() as Map<String, dynamic>;
    final int currentStock = productData['Stocks'] is int
        ? productData['Stocks']
        : int.tryParse(productData['Stocks'].toString()) ?? 0;

    if (checked && !stockUpdated) {
      if (currentStock < quantity) {
        print("Stock insuffisant.");
        return;
      }
      final newStock = currentStock - quantity;
      await productRef.update({'Stocks': newStock});
      await produit.reference.update({'isChecked': true, 'stockUpdated': true});
    } else if (!checked && stockUpdated) {
      final restoredStock = currentStock + quantity;
      await productRef.update({'Stocks': restoredStock});
      await produit.reference.update({'isChecked': false, 'stockUpdated': false});
    } else {
      await produit.reference.update({'isChecked': checked});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suivi de livraison')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun produit dans le panier.'));
          }

          var produits = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffB81736), Color(0xff281537)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  "Veuillez cocher\nles produits déjà livrés !",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: produits.length,
                    itemBuilder: (context, index) {
                      var produit = produits[index];
                      String title = produit['title'] ?? 'Sans titre';
                      double price = produit['price'] is double
                          ? produit['price']
                          : double.tryParse(produit['price'].toString()) ?? 0.0;

                      bool isChecked = false;
                      if (produit.data().toString().contains('isChecked')) {
                        isChecked = produit['isChecked'] == true;
                      } else {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('cart')
                            .doc(produit.id)
                            .update({'isChecked': false});
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CheckboxListTile(
                          title: Text('$title - ${price.toStringAsFixed(0)} FCFA'),
                          subtitle: isChecked
                              ? const Text('✅ Livraison effectuée')
                              : const Text('En attente'),
                          value: isChecked,
                          onChanged: (bool? newValue) async {
                            final bool checked = newValue ?? false;
                            await handleCheckChange(produit, checked);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
