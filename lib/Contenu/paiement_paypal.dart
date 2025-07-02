import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Historique_palpal.dart';

import 'map_pages.dart';

class PaiementPage extends StatefulWidget {
  final double montant;

  PaiementPage({required this.montant});

  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage>
{
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _numeroCarteController = TextEditingController();
  final TextEditingController _dateExpirationController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  late double montantTotal;

  @override
  void initState() {
    super.initState();
    _initialiserNotifications(); // <-- appel de l'init
    montantTotal = widget.montant;
  }


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); // <-- déclaration ici

  Future<void> _initialiserNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _envoyerNotificationPaiement() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'paiement_channel',
      'Paiement',
      channelDescription: 'Notification après paiement réussi',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Paiement réussi',
      'Votre paiement de ${montantTotal.toStringAsFixed(2)} FCFA a été effectué avec succès.',
      platformChannelSpecifics,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset("assets/images/carte.jpeg", height: 100),
            SizedBox(height: 20),
            Text(
              "Montant total à payer : ${montantTotal.toStringAsFixed(2)} FCFA",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: "Nom sur la carte",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _numeroCarteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Numéro de carte",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateExpirationController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: "Date d'expiration",
                      hintText: "MM/AA",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _effectuerPaiementAvecPayPal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Payer avec PayPal"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HistoriquePaiementPage()));
              },
              child: Text("Historique de Paiement"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapPage()));
              },
              child: Text("Carte Map"),
            ),
          ],
        ),
      ),
    );
  }

  /// Fonction appelée quand on clique sur "Payer avec PayPal"
  Future<void> _effectuerPaiementAvecPayPal() async {
    final nom = _nomController.text.trim();
    final numeroCarte = _numeroCarteController.text.trim();
    final expiration = _dateExpirationController.text.trim();
    final cvv = _cvvController.text.trim();

    if (nom.isEmpty || numeroCarte.isEmpty || expiration.isEmpty || cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez remplir tous les champs")));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://keith.wuaze.com/Paiement.php?amount=$montantTotal"),
      );

      final data = jsonDecode(response.body);
      final approvalUrl = data['links'].firstWhere((link) => link['rel'] == 'approve')['href'];

      if (await canLaunchUrl(Uri.parse(approvalUrl))) {
        await launchUrl(Uri.parse(approvalUrl), mode: LaunchMode.externalApplication);

        /// 🔥 Supprimer le panier après paiement
        await _viderPanierApresPaiement();
        await _envoyerNotificationPaiement();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Paiement lancé et panier vidé.")));

        /// 🔄 Retour à la page d'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapPage()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Impossible d'ouvrir PayPal.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de paiement : $e")));
    }
  }

  /// 🔄 Supprime tous les articles du panier de l'utilisateur connecté
  Future<void> _viderPanierApresPaiement() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final snapshot = await cartRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }
}
