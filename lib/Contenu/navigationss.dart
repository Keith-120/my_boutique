import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Acceuilless.dart';
import 'Article_Panier_.dart';
import 'Recuperation_d adresse_client.dart';
import 'Statu_livraison.dart';
import 'Statut_livraison_client.dart';
import 'Tout_Categorie.dart';

class test_navigations extends StatefulWidget {
  const test_navigations({super.key});

  @override
  State<test_navigations> createState() => _test_navigationsState();
}

class _test_navigationsState extends State<test_navigations> {
  int test1 = 0;
  String? _userRole;
  String? selectedUserId; // Utilisé par l'admin pour consulter un utilisateur

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    if (currentUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('user')
          .doc(currentUser!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _userRole = snapshot.get('role');
          selectedUserId = currentUser!.uid; // par défaut, soi-même
        });
      }
    }
  }

  void setCurrentIndex(index) {
    setState(() {
      test1 = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🧭 Génère dynamiquement les titres et pages
    final isAdmin = _userRole == 'admin';
    List<Widget> pages = [
      Acceuilless(),
      ToutCategorie(),
      CartPage(),
      if(_userRole == 'admin') OrderSummaryPage(),
      isAdmin ? AdminPage() : ClientPage()

     // Statut Livraison
    ];

    List<Widget> titles = [
      Text("Accueil"),
      Text("Produit"),
      Text("Achat"),
      if (_userRole == 'admin') Text("Livraison"),
      Text("Statut Livraison"),
    ];

    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Produits"),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Achat"),
      if (_userRole == 'admin')
        BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: "Livraison"),
      BottomNavigationBarItem(icon: Icon(Icons.description), label: "Statut Livraison"),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Affiche une boîte de dialogue de confirmation
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmer la sortie'),
            content: Text('Voulez-vous vraiment quitter l\'application ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Non'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Oui'),
              ),
            ],
          ),
        );

        // Si l'utilisateur appuie sur "Oui", on quitte l'application
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: titles[test1],
          actions: _userRole == 'admin' && test1 == (navItems.length - 1)
              ? [
            IconButton(
              icon: Icon(Icons.switch_account),
              onPressed: () async {
                // Optionnel : ouvrir un dialogue pour changer d'utilisateur à visualiser
                var newId = await _selectUserIdDialog(context);
                if (newId != null) {
                  setState(() {
                    selectedUserId = newId;
                  });
                }
              },
            )
          ]
              : null,
        ),
        body: pages[test1],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: test1,
          items: navItems,
          onTap: setCurrentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  // ✅ Petit dialogue pour admin pour changer de client
  Future<String?> _selectUserIdDialog(BuildContext context) async {
    List<DocumentSnapshot> userDocs = (await FirebaseFirestore.instance
        .collection('users')
        .get())
        .docs;

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Voir les livraisons de :"),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              var doc = userDocs[index];
              return ListTile(
                title: Text(doc['nom']),
                subtitle: Text(doc['phone']),
                onTap: () => Navigator.of(context).pop(doc.id),
              );
            },
          ),
        ),
      ),
    );
  }
}
