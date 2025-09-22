import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liste_aut/Contenu/navigations.dart';
import 'OrangeMoneyPage.dart';
import 'MoovMoneyPage.dart';

class Panier_page extends StatefulWidget {
  @override
  Panier_pageState createState() => Panier_pageState();
}

class Panier_pageState extends State<Panier_page> {
  List<Map<String, dynamic>> cartItems = [];
  double total = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Recupere_element();
  }

  Future<void> Recupere_element() async {
    User? user = FirebaseAuth.instance.currentUser;
    double somme = 0.0;
    List<Map<String, dynamic>> items = [];

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart_temp')
          .get();

      for (var doc in snapshot.docs) {
        double montant = doc['price'].toDouble() * (doc['Quantite'] ?? 1);
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

  Future<void> Supprime_element(String docId, int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart_temp')
          .doc(docId)
          .delete();

      Fluttertoast.showToast(msg: "Article retiré du panier");

      setState(() {
        total -= cartItems[index]['price'] * (cartItems[index]['Quantite'] ?? 1);
        cartItems.removeAt(index);
      });
    }
  }

  void showPaymentModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choisir le mode de paiement"),
        content: Text("Veuillez sélectionner votre mode de paiement :"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToPayment('OrangeMoney');
            },
            child: Text("Orange Money"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToPayment('MoovMoney');
            },
            child: Text("Moov Money"),
          ),
        ],
      ),
    );
  }

  void navigateToPayment(String paymentMethod) {
    if (paymentMethod == 'OrangeMoney') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrangeMoneyPage(
            montant: total,
            cartItems: cartItems,
          ),
        ),
      );
    } else if (paymentMethod == 'MoovMoney') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoovMoneyPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

        Container(
        height: double.infinity,
          width: double.infinity,
         decoration: BoxDecoration(
          gradient: LinearGradient(
               colors: [Color(0xffB81736), Color(0xff281537)]
          ),
        ),
          child: Column(
            children: [
              Text("Acheter \n Vos Produit en Tout Sérénité",style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),)
            ],
          ),
        ),

          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "🛒 Mon Panier",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 15),

                  // Liste des articles
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : cartItems.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 100, color: Colors.grey),
                          SizedBox(height: 20),
                          Text("Votre panier est vide",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black)),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Navigations()),
                              );
                            },
                            child: Text("Retour à la boutique"),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15)),
                          elevation: 4,
                          shadowColor: Colors.grey.withOpacity(0.3),
                          margin:
                          EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  child: Image.network(
                                    item['imageUrl'] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? "Article",
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Quantité: ${item['Quantite'] ?? 1}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Prix à droite
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${item['price']} FCFA",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => Supprime_element(
                                      item['docId'], index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Total: ${total.toStringAsFixed(2)} FCFA",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        SizedBox(height: 12),

                        SizedBox(
                          width: 200,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffB81736), Color(0xff281537)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty ? null : showPaymentModal,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.transparent, // Important pour voir le gradient
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(
                                "Payer",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
