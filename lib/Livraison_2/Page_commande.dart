import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liste_aut/Livraison_2/traking.dart';


class OrderPage extends StatelessWidget {
  final String orderId;

  const OrderPage({super.key, required this.orderId});

  Future<void> accept() async {
    await FirebaseFirestore.instance
        .collection("deliveries")
        .doc(orderId)
        .update({
      "status": "accepted",
      "driverId": "driver_1",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Commande")),
      body: Column(
        children: [
          Text("ID: $orderId"),

          ElevatedButton(
            onPressed: () async {
              await accept();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackingPage(orderId: orderId),
                ),
              );
            },
            child: const Text("Accepter"),
          ),
        ],
      ),
    );
  }
}