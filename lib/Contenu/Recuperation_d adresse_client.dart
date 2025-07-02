import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Detail_checklist_livraison_effectue.dart';

class OrderSummaryPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot)
        {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var orders = snapshot.data!.docs;
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                    ),
                  ),
                  padding: EdgeInsets.only(top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Liste des adresses \n ou nous devons assure la livraison !",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.white,
                      ),
                      height: double.infinity,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                            children: [
                              Padding(padding: EdgeInsets.only(top: 20)),
                              Align(
                                alignment: AlignmentDirectional.topCenter,
                                child: Text(
                                  "Listes Des Adresses De Livraison",
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 15)),
                              SizedBox(
                                  height: 400,
                                  child:
                                  ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      var order = orders[index];
                                      return ListTile(
                                        title: Text(order['nom']),
                                        subtitle:
                                        Container(
                                          child: Column(
                                            children: [
                                              Text(order['address']),
                                              Text(order['phone']),
                                            ],
                                          ),
                                        ),
                                        trailing: Icon(Icons.arrow_forward),
                                        onTap: () async {
                                          final currentUser = FirebaseAuth.instance.currentUser;

                                          if (currentUser == null) return;

                                          final userDoc = await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser.uid)
                                              .collection('user')
                                              .doc(currentUser.uid)
                                              .get();

                                          final currentRole = userDoc.get('role');
                                          final selectedUserId = order.id;

                                          // Autorisé si admin ou si c’est lui-même
                                          if (currentRole == 'admin' || currentUser.uid == selectedUserId) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => CartChecklistPage(userId: selectedUserId),
                                              ),
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Accès refusé"),
                                                content: Text("Vous n'avez pas l'autorisation d'accéder à cette livraison."),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text("OK"),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },

                                      );
                                    },
                                  )
                              ),
                            ]),
                      ),
                    )
                )
              ],
            ),
          );
        },
      ),
    );
  }
}