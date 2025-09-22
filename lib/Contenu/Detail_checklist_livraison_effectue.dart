import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Detail_checklist extends StatefulWidget {
  final String userId;

  const Detail_checklist({Key? key, required this.userId}) : super(key: key);

  @override
  Detail_checklistState createState() => Detail_checklistState();
}

class Detail_checklistState extends State<Detail_checklist> {
  User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getCartStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .snapshots();
  }


  Future<void> handleCheckChange(DocumentSnapshot produit, bool checked) async {
    await confirmDelivery(produit, checked);
    await Modifier_Status(); // 🔹 Mise à jour automatique du statut utilisateur
  }


  Future<void> confirmDelivery(DocumentSnapshot produit, bool checked) async {
    final data = produit.data() as Map<String, dynamic>;

    final String? articleId = data['articleId'];
    final String? collectionName = data['collectionName'] ?? data['collection'];
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
      await produit.reference.update({
        'isChecked': true,
        'stockUpdated': true,
        'deliveryDate': FieldValue.serverTimestamp(),
      });
    } else if (!checked && stockUpdated) {
      final restoredStock = currentStock + quantity;
      await productRef.update({'Stocks': restoredStock});
      await produit.reference.update({
        'isChecked': false,
        'stockUpdated': false,
        'deliveryDate': null,
      });
    } else {
      await produit.reference.update({
        'isChecked': checked,
        'deliveryDate': checked ? FieldValue.serverTimestamp() : null,
      });
    }
  }

  /// 🔹 Mise à jour du statut de l’utilisateur
  Future<void> Modifier_Status() async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .get();

    bool allChecked = cartSnapshot.docs.every((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['isChecked'] == true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'status': allChecked ? 'ok' : 'pending',
      'validatedAt': allChecked ? FieldValue.serverTimestamp() : null,
    });
  }


  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Date inconnue";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '🛒 Aucun produit dans le panier.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          var produits = snapshot.data!.docs;

          return Scaffold(
            appBar: AppBar(
              title: const Text("📦 Confirmer les livraisons"),
              backgroundColor: const Color(0xffB81736),
            ),
            body: Stack(
              children: [

                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Veuillez cocher les produits \n déjà livrés ✅",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      itemCount: produits.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        var produit = produits[index];
                        String title = produit['title'] ?? 'Sans titre';
                        double price = produit['price'] is double
                            ? produit['price']
                            : double.tryParse(produit['price'].toString()) ?? 0.0;
                        String imageUrl = produit['imageUrl'] ?? "";
                        bool isChecked =
                        (produit.data() as Map<String, dynamic>).containsKey('isChecked')
                            ? produit['isChecked'] == true
                            : false;

                        Timestamp? deliveryDate =
                        (produit.data() as Map<String, dynamic>).containsKey('deliveryDate')
                            ? produit['deliveryDate']
                            : null;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: CheckboxListTile(
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            secondary: imageUrl.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 40),
                            title: Text(
                              title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${price.toStringAsFixed(0)} FCFA",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                isChecked
                                    ? const Text(
                                  '✅ Livraison effectuée',
                                  style: TextStyle(color: Colors.green),
                                )
                                    : const Text(
                                  '⏳ En attente',
                                  style: TextStyle(color: Colors.orange),
                                ),
                                if (isChecked && deliveryDate != null)
                                  Text(
                                    "📅 Livré le : ${formatDate(deliveryDate)}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                              ],
                            ),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
