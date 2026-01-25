import 'dart:convert';
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

  String? txRef;

// 🔵 INITIATION PAIEMENT
  Future<void> initierPaiement() async {
    setState(() => _loading = true);
    txRef = "CMD-${DateTime.now().millisecondsSinceEpoch}";

    try {
      final response = await http.post(
        Uri.parse("$backendURL/create_payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tx_ref": txRef,
          "amount": widget.montant.toStringAsFixed(2),
          "email": "client@gmail.com",
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          paymentLink = data["approval_url"];
          orderId = data["paypal_order_id"];
        });
      } else {
        Fluttertoast.showToast(msg: "Erreur PayPal");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur réseau");
    }

    setState(() => _loading = false);
  }

// 🔵 VERIFIER PAIEMENT
  Future<void> finaliserPaiement() async {
    if (orderId == null) return;

    try {
      final response = await http.get(
        Uri.parse("$backendURL/verify_payment?order_id=$orderId"),
      );

      final data = jsonDecode(response.body);
      final status = data["data"]["status"];

      setState(() => paymentStatus = status);

      if (status == "COMPLETED") {
        Fluttertoast.showToast(msg: "Paiement réussi 🎉");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaiementDetailsPage(paiementId: orderId!),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Paiement non validé");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur vérification");
    }
  }

// 🔵 OUVERTURE PAYPAL
  Future<void> ouvrirPaypal() async {
    if (paymentLink == null) return;

    if (_nomCtrl.text.isEmpty ||
        _telCtrl.text.isEmpty ||
        _adresseClient == null) {
      Fluttertoast.showToast(msg: "Remplir toutes les infos");
      return;
    }

    final uri = Uri.parse(paymentLink!);
    await launchUrl(uri, mode: LaunchMode.externalApplication);

// 🔥 délai amélioré
    Future.delayed(const Duration(seconds: 8), () {
      finaliserPaiement();
    });
  }

// 🔵 MAP
  Future<void> openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPages()),
    );

    if (result != null) {
      setState(() => _adresseClient = result);
    }
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
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          Text(
            "Montant : ${widget.montant} USD",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔵 CREER PAIEMENT
          if (paymentLink == null)
            ElevatedButton(
              onPressed: initierPaiement,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Payer avec PayPal"),
            ),

          // 🔵 FORMULAIRE
          if (paymentLink != null)
            Column(
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                TextField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Téléphone"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text("Adresse"),
                  onPressed: openMap,
                ),
                if (_adresseClient != null) Text(_adresseClient!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: ouvrirPaypal,
                  child: const Text("Ouvrir PayPal"),
                ),
              ],
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: finaliserPaiement,
            child: const Text("Vérifier paiement"),
          ),

          const SizedBox(height: 10),

          Text("Statut : $paymentStatus"),
        ],
      ),
    );
  }
}
