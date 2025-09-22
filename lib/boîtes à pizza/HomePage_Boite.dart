import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:liste_aut/boîtes à pizza/Article.dart';
import 'package:liste_aut/boîtes à pizza/ArticleDetailsPage.dart';

import 'package:liste_aut/boîtes à pizza/Ajoute_Article_Page.dart';
import 'package:liste_aut/Contenu/navigations.dart';


class HomePage_Boite extends StatefulWidget {
  const HomePage_Boite({super.key});

  @override
  State<HomePage_Boite> createState() => _HomePage_BoiteState();
}

class _HomePage_BoiteState extends State<HomePage_Boite> {
  @override

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    Verifie_Admin();
  }


  Future<void> Verifie_Admin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }


  Future<List<Article>> Recupere_Articles() async {
    List<Article> allArticles = [];
    List<String> collections = ['boîtes à pizza']; // Liste des collections

    for (String collection in collections) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
      List<Article> articles = snapshot.docs.map((doc) {
        return Article.fromFirestore(doc, collection);
      }).toList();
      allArticles.addAll(articles);
    }

    return allArticles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('boîtes à pizza'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Article>>(
        future: Recupere_Articles(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }


          if (snapshot.hasError) {
            print('Erreur Firebase : ${snapshot.error}');
            return Center(child: Text('Erreur de récupération des articles'));
          }


          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun article trouvé'));
          }

          List<Article> articles = snapshot.data!;

          return Stack(
            children: [

              Container(
                height: double.infinity,
                 width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)]),
                ),
                padding: EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Sélectionnez vos gammes de produits !",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "LES PRODUITS DE BOUTIQUE",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),


                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return Card(
                              color: Colors.white, // <-- couleur blanche
                              margin: EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(10),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    article.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  article.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      '${article.price} FCFA',
                                      style: TextStyle(color: Colors.green[700]),
                                    ),
                                    Text('Stock : ${article.Stocks}', style: TextStyle(color: Colors.black54)),
                                    if (article.collectionName != null)
                                      Text(
                                        'Gamme : ${article.collectionName}',
                                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black45),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => ArticleDetailsPage(article: article),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),


      floatingActionButton: isAdmin
          ? SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        backgroundColor: Color(0xffB81736), // couleur principale
        foregroundColor: Colors.white,       // icône en blanc
        overlayColor: Colors.black,          // couleur overlay
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            backgroundColor: Color(0xffB81736), // couleur du child
            foregroundColor: Colors.white,
            child: Icon(Icons.add_circle),
            label: "Ajouter",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Ajoute_Article_Page()));
            },
          ),
          SpeedDialChild(
            backgroundColor: Color(0xff281537), // couleur différente pour le child
            foregroundColor: Colors.white,
            child: Icon(Icons.navigate_next_rounded),
            label: "Navigation",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Navigations()));
            },
          ),
        ],
      )
          : null,

    );
  }
}

