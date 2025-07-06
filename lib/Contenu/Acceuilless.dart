import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liste_aut/Contenu/Pages_Acceuille.dart';

import 'package:liste_aut/Orange/Pages_Acceuille.dart';
import 'package:liste_aut/Chips/Pages_Acceuille.dart';
import 'package:liste_aut/Produits%20en%20conserve%20et%20sauces/Acceuiles_pages.dart';

import '../Divers/Pages_Acceuille.dart';
import '../Epices, condiments & assaisonnements/Pages_Acceuille.dart';
import '../Pates & dérives/Pages_Acceuille.dart';
import '../Riz/Pages_Acceuille.dart';



class Acceuilless extends StatefulWidget {
  const Acceuilless({super.key});

  @override
  State<Acceuilless> createState() => _AcceuillessState();
}

class _AcceuillessState extends State<Acceuilless> {
  final Stream<QuerySnapshot> article_ =
      FirebaseFirestore.instance.collection('Banane').snapshots();

  //snaphots signifie de retourner des valeur insatantaner dans le flus de donner
  @override
  Widget build(BuildContext context) {
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
        body:  Stack(children: [
            Container(
              height: double.infinity,
              // ce qui signifie que le conteneur dois  settendre et remplir toute la case de largeur de l ecrant
              width: double.infinity,
              // ce qui signifie que le conteneur dois  settendre et remplir toute la case de longueur de l ecrant
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    // elle va styliser en combinante les couleur
                    colors: [Color(0xffB81736), Color(0xff281537)]),
              ),
              padding: EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Recherches \n Les Produits!",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                ]),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.white),
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                        child: Column(children: [
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Text(
                          "LES PRODUITS",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Container(
                          height: 50,
                          width: double.infinity,
                          color: Colors.white,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    child: Column(children: [
                                  CircleAvatar(
                                    child: IconButton(
                                        onPressed: () {},
                                        icon: Image.asset(
                                            "assets/images/Image.png")),
                                  ),
                                  Text("Fruits",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 5))
                                ])),
                                Padding(padding: EdgeInsets.only(left: 20)),
                                Container(
                                    child: Column(children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/pngtree-electronic-consumer-studio-photography-laptop-shopping-cart-cardboard-box-online-shopping-image_853469.jpg"),
                                  ),
                                  Text(
                                    "Annas",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 5),
                                  )
                                ])),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Container(
                                    child: Column(children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/Image.png"),
                                  ),
                                  Text(
                                    "Annas",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 5),
                                  )
                                ])),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Container(
                                    child: Column(children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/IMG-20250214-WA0087.jpg"),
                                  ),
                                  Text(
                                    "Annas",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 5),
                                  )
                                ])),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Container(
                                    child: Column(children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/stock-photo-concept-online-sopping-boxes-and-shopping-bag-with-smartphone-online-shopping-screen-1786435313.jpg"),
                                  ),
                                  Text("boissons",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 5))
                                ])),
                              ])),
                      Container(
                          width: 350,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xffB81736), Color(0xff281537)]),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40)),
                          ),
                          child: SearchBar(
                            controller: _searchController,
                            leading: Icon(Icons.search, color: Colors.white),
                            hintText: "SEARCH",
                            backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                            textStyle: MaterialStatePropertyAll(TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            )),
                            onChanged: (query) {
                              rechercherEnLive(query.trim());
                            },
                            ),

                      ),
                          if (searchResults.isNotEmpty)
                            ...searchResults.map((Haricot) => Card(
                              child: ListTile(
                                leading: Haricot['imageUrl'] != null
                                    ? Image.network(Haricot['imageUrl'], width: 50, height: 50)
                                    : Icon(Icons.shopping_basket),
                                title: Text(Haricot['title'] ?? 'Sans titre'),
                                subtitle: Text("Prix: ${Haricot['price']?.toString() ?? '---'} FCFA"),
                                onTap: () {

                                },
                              ),
                            ))
                          else if (_searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("Aucun résultat trouvé.",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                      SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/IMG-20250214-WA0084.jpg'),
                                      ),
                                      Text("Cube Maggie"),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/pngtree-electronic-consumer-studio-photography-laptop-shopping-cart-cardboard-box-online-shopping-image_853469.jpg'),
                                      ),
                                      Text("Cube Maggie"),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/stock-photo-concept-online-sopping-boxes-and-shopping-bag-with-smartphone-online-shopping-screen-1786435313.jpg'),
                                      ),
                                      Text(
                                        "Cube Maggie",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/IMG-20250214-WA0088.jpg'),
                                      ),
                                      Text("Cube Maggie"),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/IMG-20250214-WA0084.jpg'),
                                      ),
                                      Text("Cube Maggie"),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 70,
                                        child: Image.asset(
                                            'assets/images/IMG-20250214-WA0087.jpg'),
                                      ),
                                      Text("Cube Maggie"),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Text("LES CATEGORIE DE PRODUITS "),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Container(
                          height: 300,
                          width: 350,
                          child: GridView(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              children: [
                                Card(
                                    child: Column(
                                  children: [
                                    Padding(padding: EdgeInsets.only(top: 25)),
                                    ListTile(
                                        leading: Image.asset(
                                            "assets/images/IMG-20250214-WA0087.jpg"),
                                        title: Text(
                                          'Haricot',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      HomePage()));
                                        }),
                                    Text('liste de categorie de haricot',
                                        style: TextStyle(fontSize: 10)),
                                    ]
                        ),
                                ),
                                    Card(
                                      child: Column(
                                        children: [
                                          Padding(padding: EdgeInsets.only(top: 25)),
                                          ListTile(
                                              leading: Image.asset(
                                                  "assets/images/IMG-20250214-WA0088.jpg"),
                                              title: Text(
                                                'articles',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                        pageBuilder: (_, __,
                                                                ___) =>
                                                            HomePage_Chips()));
                                              }),
                                          Text(
                                            'la liste des Categorie de Chips',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Card(
                                      child: Column(children: [
                                        Padding(padding: EdgeInsets.only(top: 25)),
                                        ListTile(
                                            leading: Image.asset(
                                                "assets/images/IMG-20250214-WA0084.jpg"),
                                            title: Text('Oranges',
                                                style: TextStyle(fontSize: 15)),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          HomePage_Orange()));
                                            }),
                                        Text(
                                          'liste des categorie d orange ',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ]),
                                    ),

                                Card(
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.only(top: 25)),
                                      ListTile(
                                          leading: Image.asset(
                                              "assets/images/IMG-20250214-WA0085.jpg"),
                                          title: Text(
                                            'Produits en conserve et sauces',
                                            style: TextStyle(fontSize: 8),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage_Produit_conserve()));
                                          }),
                                      Text(
                                        'les meilleurs Produits en conserve et sauces ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ]))
                                ,
                                Card(
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.only(top: 25)),
                                      ListTile(
                                          leading: Image.asset(
                                              "assets/images/IMG-20250214-WA0085.jpg"),
                                          title: Text(
                                            'Riz',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage_Riz()));
                                          }),
                                      Text(
                                        'le RIZ blanc ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ])),
                                Card(
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.only(top: 25)),
                                      ListTile(
                                          leading: Image.asset(
                                              "assets/images/téléchargement (1).jpeg"),
                                          title: Text(
                                            'Pâtes & dérivés',
                                            style: TextStyle(fontSize: 8),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage_pates()));
                                          }),
                                      Text(
                                        'les meilleurs Pâtes & dérivés ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ])),
                                Card(
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.only(top: 25)),
                                      ListTile(
                                          leading: Image.asset(
                                              "assets/images/téléchargement (3).jpeg"),
                                          title: Text(
                                            'Divers',
                                            style: TextStyle(fontSize: 8),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage_Divers()));
                                          }),
                                      Text(
                                        'les Produits Divers ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ])),   Card(
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.only(top: 25)),
                                      ListTile(
                                          leading: Image.asset(
                                              "assets/images/téléchargement.jpeg"),
                                          title: Text(
                                            'Épices, condiments & assaisonnements',
                                            style: TextStyle(fontSize:8),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        HomePage_Epices()));
                                          }),
                                      Text(
                                        'les meilleurs Épices, condiments & assaisonnements ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ])),
                                  ],
                                ))
                              ]))
                    ))
          ])
          )

    );
  }
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<String> allCollections = [
    'Haricot',
    'Chips',
    'articles',
    'Divers',
    'Produits secs',
    'Pâtes & dérivés',
    'Produits en conserve et sauces',
    'Épices, condiments & assaisonnements',
  ];

  void rechercherEnLive(String query) async
  {
    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    List<Map<String, dynamic>> results = [];

    for (String collection in allCollections) {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['collection'] = collection;
        results.add(data);
      }
    }

    setState(() {
      searchResults = results;
    });
  }

}
