import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Status_ClientPage.dart';
import 'Delivery_status_admin.dart';
import 'Detail_checklist_livraison_effectue.dart';

class  resume_commande extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Deux onglets : En attente / Livrés
      child: Scaffold(
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
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: const Text(
                "Liste des adresses \n où nous devons assurer la livraison !",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Listes Des Adresses De Livraison",
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                    ),
                    const SizedBox(height: 10),


                    const TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color(0xffB81736),
                      ),
                      tabs: [
                        Tab(text: "⏳ En attente"),
                        Tab(text: "✅ Livrés"),
                      ],
                    ),
                    const SizedBox(height: 10),


                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                          var orders = snapshot.data!.docs;


                          var pendingOrders = orders.where((order) {
                            var data = order.data() as Map<String, dynamic>;
                            return data['status'] != 'ok';
                          }).toList();

                          var deliveredOrders = orders.where((order) {
                            var data = order.data() as Map<String, dynamic>;
                            return data['status'] == 'ok';
                          }).toList();

                          return TabBarView(
                            children: [

                              ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: pendingOrders.length,
                                itemBuilder: (context, index) {
                                  var order = pendingOrders[index];
                                  var data = order.data() as Map<String, dynamic>;

                                  String nom = data['nom'] ?? "Nom inconnu";
                                  String address = data['address'] ?? "Adresse inconnue";
                                  String phone = data['phone'] ?? "Non défini";
                                  Timestamp? sendDate = data['sendDate'];
                                  String dateEnvoi = sendDate != null
                                      ? "${sendDate.toDate().day}/${sendDate.toDate().month}/${sendDate.toDate().year}"
                                      : "Date inconnue";

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      title: Text(nom),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Adresse: $address"),
                                          Text("Téléphone: $phone"),
                                          Text("Envoyé le: $dateEnvoi"),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [

                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.green),
                                            tooltip: "Marquer comme livré",
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(order.id)
                                                  .update({'status': 'ok'});
                                            },
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              "⏳ En attente",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Detail_checklist(userId: order.id),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),


                              ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: deliveredOrders.length,
                                itemBuilder: (context, index) {
                                  var order = deliveredOrders[index];
                                  var data = order.data() as Map<String, dynamic>;

                                  String nom = data['nom'] ?? "Nom inconnu";
                                  String address = data['address'] ?? "Adresse inconnue";
                                  String phone = data['phone'] ?? "Non défini";
                                  Timestamp? sendDate = data['sendDate'];
                                  String dateEnvoi = sendDate != null
                                      ? "${sendDate.toDate().day}/${sendDate.toDate().month}/${sendDate.toDate().year}"
                                      : "Date inconnue";

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      title: Text(nom),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("adresse: $address"),
                                          Text("téléphone: $phone"),
                                          Text("envoye le: $dateEnvoi"),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "livreess ✅ OK",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Detail_checklist(userId: order.id),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),


                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminPage()),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffB81736), Color(0xff281537)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: 180,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Text(
                            "Etat De Livraison",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
