import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liste_aut/Contenu/navigationss.dart';

import 'paiement_paypal.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  double total = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    double somme = 0.0;
    List<Map<String, dynamic>> items = [];

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      for (var doc in snapshot.docs) {
        double montant = doc['price'].toDouble();
        somme += montant;
        var data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        items.add(data);
      }
    }

    setState(() {
      cartItems = items;
      total = somme;
      isLoading = false;
    });
  }

  Future<void> removeCartItem(String docId, int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(docId)
          .delete();

      Fluttertoast.showToast(msg: "Article retiré du panier");

      setState(() {
        total -= cartItems[index]['price'];
        cartItems.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
              ),
            ),
          ),
            Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Text("Liste de vos  Produits ", style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),),
    ),
            Padding(
            padding: const EdgeInsets.only(top: 80),
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
            child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 100, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  "Votre panier est vide",
                  style:
                  TextStyle(fontSize: 10, color: Colors.black),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => test_navigations()),
                    );
                  },
                  child: Text("Retour à la boutique"),
                )
              ],
            ),
          ),
                )
            )
        ],
      )
          : Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Text(
                  "EFFECTUEZ VOS\nCHOIX EN TOUTE LIBERTÉ",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40)),
                color: Colors.white,
              ),
              height: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "VOTRE PANIER D'ACHATS",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16),
                        ),
                        IconButton(
                          onPressed: fetchCartItems,
                          icon: Icon(Icons.refresh,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        return ListTile(
                          leading:
                          Image.network(item['imageUrl'] ?? ""),
                          title: Text(item['title'] ?? "Article"),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text('${item['price']} FCFA'),
                              Text(
                                  'Quantité: ${item['Quantite'] ?? 1}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => removeCartItem(
                                item['docId'], index),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Total: ${total.toStringAsFixed(2)} FCFA",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaiementPage(montant: total),
                        ),
                      );
                    },
                    child: Text("Procéder au Paiement"),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
