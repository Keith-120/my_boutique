import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'Adresse_livraison.dart';


class PaiementDetailsPage extends StatefulWidget {
  final String paiementId;

  const PaiementDetailsPage({super.key, required this.paiementId});

  @override
  State<PaiementDetailsPage> createState() => _PaiementDetailsPageState();
}

class _PaiementDetailsPageState extends State<PaiementDetailsPage> {
  bool _loading = false;
  Map<String, dynamic>? paymentData;

  final String backendVerifyUrl =
      "https://my-boutique-7osm.onrender.com/verify_payment";

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    loadPayment();
  }


  Future<void> loadPayment() async {
    final doc = await FirebaseFirestore.instance
        .collection("payments")
        .doc(widget.paiementId)
        .get();

    setState(() {
      paymentData = doc.data();
    });
  }


  Future<void> verifierPaiement() async {
    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse("$backendVerifyUrl?order_id=${widget.paiementId}"),
      );

      final json = jsonDecode(response.body);
      final status = json["data"]?["status"] ?? "pending";

      await FirebaseFirestore.instance
          .collection("payments")
          .doc(widget.paiementId)
          .update({"status": status});

      await loadPayment();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Statut mis à jour : $status")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur vérification paiement.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> enregistrerPositionClient() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Activez la localisation.")));
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission refusée.")));
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance
        .collection("payments")
        .doc(widget.paiementId)
        .update({
      "client_position": {
        "lat": pos.latitude,
        "lng": pos.longitude,
        "updated_at": DateTime.now().toIso8601String(),
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Position enregistrée.")),
    );


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdresseLivraisonPage(
          latitude: pos.latitude,
          longitude: pos.longitude,
          paiementId: widget.paiementId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (paymentData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du paiement", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: appGradient)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Transaction ID : ${widget.paiementId}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Text("Montant : ${paymentData!['amount']} USD"),
            Text("Utilisateur : ${paymentData!['userId']}"),

            const SizedBox(height: 10),

            Text(
              "Statut : ${paymentData!['status']}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: paymentData!['status'] == "COMPLETED"
                    ? Colors.green
                    : Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            boutonGradient(
              label: "🔄 Vérifier le paiement",
              onPressed: _loading ? null : verifierPaiement,
            ),

            const SizedBox(height: 20),

            boutonGradient(
              label: "📍 Enregistrer ma position / Livraison",
              onPressed: enregistrerPositionClient,
            ),
          ],
        ),
      ),
    );
  }

  Widget boutonGradient({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: appGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
