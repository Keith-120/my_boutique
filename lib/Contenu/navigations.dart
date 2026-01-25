import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Admin_commande_Page.dart';
import 'Etat_livraison_Client.dart';
import 'Home.dart';
import 'Panier.dart';


import 'Tout_Categories.dart';
import 'map_pages.dart';

class Navigations extends StatefulWidget {
  const Navigations({super.key});

  @override
  State<Navigations> createState() => _NavigationsState();
}

class _NavigationsState extends State<Navigations> {
  int currentIndex = 0;

  String? userRole;
  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  User? currentUser = FirebaseAuth.instance.currentUser;

  bool isLoading = true;

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    if (currentUser != null) {
      try {

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('user')
            .doc(currentUser!.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            userRole = snapshot.get('role');
            userName = snapshot.get('nom');
            userEmail = snapshot.get('email');
            userPhotoUrl = snapshot.get('photoUrl') ??
                "https://cdn-icons-png.flaticon.com/512/149/149071.png";
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint("Erreur récupération utilisateur : $e");
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(

        body: Center(
            child: CircularProgressIndicator(
              color: Color(0xffB81736),
            )),
      );
    }

    final bool isAdmin = userRole == 'admin';
    final bool isClient = userRole == 'client';


    List<Widget> pages = [
      Home(),
      ToutCategorie(),
      Panier_page(),
      MapPage(),
      if (isAdmin) AdminCommandesPage(),
      if (isClient) MesLivraisonsPage(),
    ];


    if (currentIndex >= pages.length) currentIndex = 0;


    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: "Accueil",
      ),

      const BottomNavigationBarItem(
        icon: Icon(Icons.category_outlined),
        activeIcon: Icon(Icons.category_rounded),
        label: "Produits",
      ),

      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_basket_outlined),
        activeIcon: Icon(Icons.shopping_basket_rounded),
        label: "Panier",
      ),

      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map_rounded),
        label: "Carte",
      ),

      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping_rounded),
          label: "Commandes",
        ),

      if (isClient)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: "Suivi",
        ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),

        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                userPhotoUrl ??
                    "https://cdn-icons-png.flaticon.com/512/149/149071.png",
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? "Utilisateur",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  userEmail ?? currentUser?.email ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),


        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {


                case 'admin_commandes':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminCommandesPage()),
                  );
                  break;


                case 'map_livreur':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapPage()),
                  );
                  break;


                case 'mes_livraisons':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MesLivraisonsPage()),
                  );
                  break;


                case 'logout':
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                        (_) => false,
                  );
                  break;
              }
            },

            itemBuilder: (context) => [


              if (userRole == 'admin')
                const PopupMenuItem(
                  value: 'admin_commandes',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 10),
                      Text("Gestion commandes"),
                    ],
                  ),
                ),


              if (userRole == 'livreur')
                const PopupMenuItem(
                  value: 'map_livreur',
                  child: Row(
                    children: [
                      Icon(Icons.map),
                      SizedBox(width: 10),
                      Text("Carte livraisons"),
                    ],
                  ),
                ),


              if (userRole == 'client')
                const PopupMenuItem(
                  value: 'mes_livraisons',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long),
                      SizedBox(width: 10),
                      Text("Mes livraisons"),
                    ],
                  ),
                ),

              const PopupMenuDivider(),


              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Déconnexion"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),


      body: SafeArea(
        top: false,
        child: pages[currentIndex],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            selectedItemColor: const Color(0xffB81736),
            unselectedItemColor: Colors.black54,
            showUnselectedLabels: true,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
