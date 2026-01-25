import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liste_aut/Contenu/navigations.dart';
import 'Paypal.dart';

class Panier_page extends StatefulWidget {
  @override
  Panier_pageState createState() => Panier_pageState();
}

class Panier_pageState extends State<Panier_page> {
  List<Map<String, dynamic>> cartItems = [];
  double total = 0.0;
  bool isLoading = true;

  @override
  void initState()
  {
    super.initState();
    Recupere_element();
  }


  Future<void> Recupere_element() async
  {
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
        var data = doc.data() as Map<String, dynamic>;


        double price = ((data['price'] ?? 0) as num).toDouble();
        int qty = ((data['Quantite'] ?? 1) as num).toInt();

        somme += price * qty;

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

      double price = ((cartItems[index]['price'] ?? 0) as num).toDouble();
      int qty = ((cartItems[index]['Quantite'] ?? 1) as num).toInt();

      setState(() {
        total -= price * qty;
        cartItems.removeAt(index);
      });

      Fluttertoast.showToast(msg: "🗑️ Article retiré du panier");
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
            child: Text("Orange Money", style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToPayment('MoovMoney');
            },
            child: Text("Moov Money", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToPayment('Paypal');
            },
            child: Text("Paypal", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }


  void navigateToPayment(String paymentMethod) {
    switch (paymentMethod) {
      case 'Paypal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPaymentPage(
              montant: total,
            ),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Méthode de paiement non supportée"),
            backgroundColor: Colors.red,
          ),
        );
    }
  }



  Future<void> enregistrerCommande() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String numeroCommande =
        "CMD-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("orders")
        .doc(numeroCommande)
        .set({
      "numeroCommande": numeroCommande,
      "userId": user.uid,
      "email": user.email ?? "",
      "montant": total,
      "status": "en_attente_validation",
      "dateCommande": FieldValue.serverTimestamp(),
      "articles": cartItems,
    });

    Fluttertoast.showToast(
      msg: " Commande enregistrée sous $numeroCommande",
      backgroundColor: Colors.green,
    );
  }

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🛒 Mon Panier",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : cartItems.isEmpty
                        ? emptyCart()
                        : cartList(),
                  ),
                  bottomBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Panier vide
  Widget emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart, size: 90, color: Colors.grey),
          SizedBox(height: 10),
          Text("Votre panier est vide",
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Navigations()),
              );
            },
            child: Text("🛍️ Retour à la boutique"),
          ),
        ],
      ),
    );
  }

  /// Liste des articles
  Widget cartList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        var item = cartItems[index];

        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['imageUrl'] ??
                    "https://via.placeholder.com/150",
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              item['title'] ?? "Article",
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            subtitle: Text(
              "Quantité: ${item['Quantite'] ?? 1}",
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item['price']} FCFA",
                  style: TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () =>
                      Supprime_element(item['docId'], index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Barre du bas
  Widget bottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.grey.shade300),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Total: ${total.toStringAsFixed(2)} FCFA",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: cartItems.isEmpty
                ? null
                : () async {
              await enregistrerCommande();
              showPaymentModal();
            },
            icon: Icon(Icons.payment, color: Colors.white),
            label: Text("Procéder au paiement"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
