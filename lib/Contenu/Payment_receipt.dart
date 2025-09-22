import 'package:flutter/material.dart';

class RecuPage extends StatelessWidget {
  final double montant;
  final String numeroClient;
  final String transactionId;

  RecuPage({
    required this.montant,
    required this.numeroClient,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reçu de Paiement")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("✅ Paiement effectué avec succès !",
                style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 20),

            Text("Montant : ${montant.toStringAsFixed(2)} FCFA",
                style: TextStyle(fontSize: 18)),

            Text("Numéro client : $numeroClient",
                style: TextStyle(fontSize: 18)),

            Text("ID Transaction : $transactionId",
                style: TextStyle(fontSize: 18)),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst); // Retour accueil
                },
                child: Text("Retour à l'accueil"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
