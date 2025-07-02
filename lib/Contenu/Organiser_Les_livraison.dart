import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Detail_checklist_livraison_effectue.dart'; // CartChecklistPage

class IconConfirmation extends StatefulWidget {
  @override
  _IconConfirmationState createState() => _IconConfirmationState();
}

class _IconConfirmationState extends State<IconConfirmation> {
  String? selectedUserId;
  List<Map<String, dynamic>> usersList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      setState(() {
        usersList = snapshot.docs
            .map((doc) => {
          'id': doc.id,
          'name': doc['name'] ?? 'Nom inconnu',
        })
            .toList();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur lors de la récupération des utilisateurs : $e");
    }
  }

  Future<void> _handleDeliveryAccess() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || selectedUserId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUserId)
          .get();

      final currentRole = userDoc.data()?['role'] ?? 'client';

      if (currentRole == 'admin' || currentUser.uid == selectedUserId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CartChecklistPage(userId: selectedUserId!),
          ),
        );
      } else {
        _showAccessDenied();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur lors de l'accès : $e");
    }
  }

  void _showAccessDenied() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vos livraisons")),
      body: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "Confirmation de livraison",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Sélectionnez un utilisateur pour voir l'état de la livraison"),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedUserId,
                    hint: Text("Choisir un utilisateur"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedUserId = newValue;
                      });
                    },
                    items: usersList.map<DropdownMenuItem<String>>((user) {
                      return DropdownMenuItem<String>(
                        value: user['id'],
                        child: Text(user['name']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleDeliveryAccess,
                    child: Text("Voir l'état de la livraison"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
