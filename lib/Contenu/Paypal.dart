
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'detail_paiement.dart';
import 'maps_paypal.dart';

class PaypalPaymentPage extends StatefulWidget {
  final double montant;
  const PaypalPaymentPage({super.key, required this.montant});

  @override
  State<PaypalPaymentPage> createState() => _PaypalPaymentPageState();
}

class _PaypalPaymentPageState extends State<PaypalPaymentPage> {
  bool _loading = false;
  String? paymentLink;
  String? orderId;
  String paymentStatus = "En attente";

  final backendURL = "https://my-boutique-7osm.onrender.com";

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  String? _adresseClient;


  Future<void> initierPaiement() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "Connectez-vous");
      return;
    }

    setState(() => _loading = true);
    final txRef = "CMD-${DateTime.now().millisecondsSinceEpoch}";

    await FirebaseFirestore.instance.collection("payments").doc(txRef).set({
      "userId": user.uid,
      "amount": widget.montant,
      "paypal_order_id": null,
      "status": "pending",
      "created_at": FieldValue.serverTimestamp(),
    });

    try {
      final response = await http.post(
        Uri.parse("$backendURL/create_payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tx_ref": txRef,
          "amount": widget.montant.toStringAsFixed(2),
          "email": user.email ?? "client@gmail.com",
        }),
      );

      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        paymentLink = data["approval_url"];
        orderId = data["paypal_order_id"];

        await FirebaseFirestore.instance
            .collection("payments")
            .doc(txRef)
            .update({"paypal_order_id": orderId});
      } else {
        Fluttertoast.showToast(msg: "Erreur PayPal");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur réseau");
    }

    setState(() => _loading = false);
  }


  Future<void> verifierPaiement() async {
    if (orderId == null) return;

    final response = await http.get(
      Uri.parse("$backendURL/verify_payment?order_id=$orderId"),
    );

    final data = jsonDecode(response.body);
    final status = data["data"]["status"];

    setState(() => paymentStatus = status);

    FirebaseFirestore.instance
        .collection("payments")
        .where("paypal_order_id", isEqualTo: orderId)
        .limit(1)
        .get()
        .then((snap) {
      if (snap.docs.isNotEmpty) {
        snap.docs.first.reference.update({"status": status});
      }
    });

    if (status == "COMPLETED") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaiementDetailsPage(paiementId: orderId!),
        ),
      );
    }
  }


  Future<void> _openPaymentPage() async {
    if (paymentLink == null) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Informations de livraison"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("📍 Récupérer l’adresse"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  MapPages()),
                  );

                  if (result != null) {
                    setState(() => _adresseClient = result);
                  }
                },
              ),

              if (_adresseClient != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_adresseClient!,
                      style: const TextStyle(fontSize: 13)),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Continuer vers PayPal"),
              onPressed: () async {
                if (_nomCtrl.text.isEmpty ||
                    _telCtrl.text.isEmpty ||
                    _adresseClient == null) {
                  Fluttertoast.showToast(
                      msg: "Veuillez remplir toutes les informations");
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(user.uid)
                      .set({
                    "nom": _nomCtrl.text,
                    "telephone": _telCtrl.text,
                    "adresse": _adresseClient,
                  }, SetOptions(merge: true));
                }

                Navigator.pop(context);

                final uri = Uri.parse(paymentLink!);
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _choisirLivraison() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          title: const Text("Livraison"),
          content: const Text(
            "Souhaitez-vous que la commande soit livrée ?",
          ),
          actions: [
            TextButton(
              child: const Text("❌ Sans livraison"),
              onPressed: () async {
                Navigator.pop(context);

                // 👉 continuer directement vers PayPal
                final uri = Uri.parse(paymentLink!);
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            ElevatedButton(
              child: const Text("✅ Avec livraison"),
              onPressed: () {
                Navigator.pop(context);
                _openPaymentPage();
              },
            ),
          ],
        );
      },
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
      appBar: AppBar(
        title: const Text("Paiement PayPal"),
        flexibleSpace:
        Container(decoration: BoxDecoration(gradient: appGradient)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text("Montant : ${widget.montant} USD",
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          if (paymentLink == null)
            ElevatedButton(
              onPressed: initierPaiement,
              child: _loading
                ? CircularProgressIndicator(color: Colors.white)
                : const Text(
                  "Payer avec PayPal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,))
            ),

          if (paymentLink != null)
            ElevatedButton(
              onPressed:  _choisirLivraison,
              child: const Text("🟦 Ouvrir PayPal"),
            ),

          ElevatedButton(
            onPressed: verifierPaiement,
            child: const Text("Vérifier le statut"),
          ),

          Text("Statut : $paymentStatus"),
        ],
      ),
    );
  }
}
