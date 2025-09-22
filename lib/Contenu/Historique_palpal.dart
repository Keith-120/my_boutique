import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoriquePaiementPage extends StatefulWidget {
  @override
  HistoriquePaiementPageState createState() => HistoriquePaiementPageState();
}

class HistoriquePaiementPageState extends State<HistoriquePaiementPage> {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child('paiements');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Historique des Paiements")),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map data = snapshot.data!.snapshot.value as Map;
            List paiements = data.entries.map((e) => e.value).toList();

            return ListView.builder(
              itemCount: paiements.length,
              itemBuilder: (context, index) {
                final paiement = paiements[index];
                return ListTile(
                  title: Text(paiement['payer_name'] ?? 'Inconnu'),
                  subtitle: Text("${paiement['amount']} ${paiement['currency']}"),
                  trailing: Text(paiement['status']),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
