import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_pages.dart';

class OrangeMoneyPage extends StatefulWidget {
  final double montant;
  final List<Map<String, dynamic>> cartItems;

  OrangeMoneyPage({required this.montant, required this.cartItems});

  @override
  OrangeMoneyPageState createState() => OrangeMoneyPageState();
}

class OrangeMoneyPageState extends State<OrangeMoneyPage> {
  bool souhaiteLivraison = true;
  final TextEditingController nomController = TextEditingController();
  final TextEditingController telController = TextEditingController();


  Future<void> enregistrer_Infos_Utilisateur({required bool livraison}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection("users").doc(
        user.uid);

    Map<String, dynamic> data = {
      "souhaiteLivraison": livraison,
    };

    if (!livraison) {

      data.addAll({
        "nom": nomController.text.trim(),
        "phone": telController.text.trim(),
        "sendDate": FieldValue.serverTimestamp(),

      });
    }

    await userRef.set(data, SetOptions(merge: true));
  }



  Future<void> enregistrer_Paiement() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String numeroAchat = "CMD-${DateTime
          .now()
          .millisecondsSinceEpoch}";

      final userCartRef =
      FirebaseFirestore.instance.collection("users").doc(user.uid);

      QuerySnapshot snapshot = await userCartRef.collection("cart_temp").get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        await userCartRef.collection("cart").add({
          "numeroAchat": numeroAchat,
          "userId": user.uid,
          "articleId": data['articleId'] ?? doc.id,
          "collectionName": data['collection'] ?? 'Produits',
          "quantite": data['Quantite'] ?? 1,
          "price": data['price'] ?? 0,
          "title": data['title'] ?? "Produit sans titre",
          "imageUrl": data['imageUrl'] ?? "",
          "montantTotal": (data['price'] ?? 0) * (data['Quantite'] ?? 1),
          "datePaiement": FieldValue.serverTimestamp(),
          "statut": "En attente",
        });
      }

      for (var doc in snapshot.docs) {
        await userCartRef.collection("cart_temp").doc(doc.id).delete();
      }

      Fluttertoast.showToast(
        msg: "Paiement enregistré ✅ \n Numéro: $numeroAchat",
        gravity: ToastGravity.CENTER,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur Firebase : $e");
    }
  }


  Future<void> lancer_Paiement() async {
    String numero = "#144#1#1#74584046#${widget.montant.toInt()}#";
    String url = "tel:${Uri.encodeComponent(numero)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "Impossible d’ouvrir $url");
    }
  }


  Future<void> payer_Maintenant() async {
    if (!souhaiteLivraison) {
      if (nomController.text.isEmpty || telController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Nom et Téléphone requis !");
        return;
      }
    }

    await enregistrer_Infos_Utilisateur(livraison: souhaiteLivraison);
    await enregistrer_Paiement();


    await lancer_Paiement();
  }

  @override

    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [


              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffB81736), Color(0xff281537)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text(
                      "Paiement Orange Money",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            "Souhaitez-vous être livré ?",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: souhaiteLivraison,
                          onChanged: (val) {
                            setState(() => souhaiteLivraison = val);
                          },
                        ),
                        if (!souhaiteLivraison) ...[
                          SizedBox(height: 10),
                          TextField(
                            controller: nomController,
                            decoration: InputDecoration(
                              labelText: "Nom",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: telController,
                            decoration: InputDecoration(
                              labelText: "Téléphone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          "Montant à payer : ${widget.montant} FCFA",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),


                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffB81736), Color(0xff281537)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: payer_Maintenant,
                            child: Text(
                              "Confirmer et payer",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),


                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade800
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: souhaiteLivraison
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MapPage()),
                              );
                            }
                                : null,
                            child: Text(
                              "Adresse de livraison",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }
