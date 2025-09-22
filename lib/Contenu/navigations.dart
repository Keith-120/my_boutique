import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Pages importées
import 'Home.dart';
import 'Panier.dart';
import 'resume_commande.dart';
import 'Delivery_status_admin.dart';
import 'Status_ClientPage.dart';
import 'Login.dart';
import 'Tout_Categories.dart';
import 'map_pages.dart';


class LocalisationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.blueAccent),
          SizedBox(height: 16),
          Text(
            "Page Localisation",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Ici vous pouvez intégrer Google Maps ou Leaflet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}


class Navigations extends StatefulWidget {
  const Navigations({super.key});

  @override
  State<Navigations> createState() => _NavigationsState();
}

class _NavigationsState extends State<Navigations> {
  int test1 = 0;
  String? userRole;
  String? selectedUserId;

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
          userRole = snapshot.get('role');
          selectedUserId = currentUser!.uid;
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
    final isAdmin = userRole == 'admin';


    List<Widget> pages = [
      Home(),
      ToutCategorie(),
      Panier_page(),
      MapPage(), // Localisation
      if (isAdmin) resume_commande(),
      if (userRole == 'client') ClientPage()
    ];


    List<Widget> titles = [
      Text("Accueil"),
      Text("Produits"),
      Text("Panier"),
      Text("Localisation"),
      if (isAdmin) Text("Commandes"),
      if (userRole == 'client') Text("Suivi Livraison"),
    ];


    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Accueil"),
      BottomNavigationBarItem(icon: Icon(Icons.category), label: "Produits"),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: "Panier"),
      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Localisation"),
      if (isAdmin)
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Commandes"),
      if (userRole == 'client')
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Suivi"),
    ];

    return WillPopScope(
      onWillPop: () async {
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
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: titles[test1],
          actions: [

            IconButton(
              icon: Icon(Icons.account_circle_rounded, size: 28),
              onPressed: () async {
                User? currentUser = FirebaseAuth.instance.currentUser;


                String nom = "Inconnu";
                String email = "Inconnu";
                String uid = "Inconnu";

                if (currentUser != null) {
                  email = currentUser.email ?? "Inconnu";
                  uid = currentUser.uid;

                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();

                  if (userDoc.exists) {
                    nom = userDoc.get('nom') ?? "Inconnu";
                  }
                }

                showGeneralDialog(
                  context: context,
                  barrierLabel: "Profil",
                  barrierDismissible: true,
                  transitionDuration: Duration(milliseconds: 300),
                  pageBuilder: (context, anim1, anim2) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26, blurRadius: 10, offset: Offset(-2, 0))
                            ],
                          ),
                          child: Column(
                            children: [

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xffB81736), Color(0xff281537)],
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person, size: 50, color: Color(0xffB81736)),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      nom,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: Icon(Icons.email, color: Colors.redAccent),
                                        title: Text(email),
                                      ),
                                    ),
                                    Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: ListTile(
                                        leading: Icon(Icons.vpn_key, color: Colors.redAccent),
                                        title: Text(uid),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  transitionBuilder: (context, anim1, anim2, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(anim1),
                      child: child,
                    );
                  },
                );
              },
            ),

          ],
        ),

        body: pages[test1],


        bottomNavigationBar: BottomNavigationBar(
          currentIndex: test1,
          items: navItems,
          onTap: setCurrentIndex,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
