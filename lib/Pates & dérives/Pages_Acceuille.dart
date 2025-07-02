import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:liste_aut/Pates & dérives/Recuperation_Donnees.dart';
import 'package:liste_aut/Pates & dérives/Detaille_article.dart';

import 'package:liste_aut/Pates & dérives/Ajouter_Liste.dart';
import 'package:liste_aut/Contenu/navigationss.dart';


class HomePage_pates extends StatefulWidget {
  const HomePage_pates({super.key});

  @override
  State<HomePage_pates> createState() => _HomePage_patesState();
}

class _HomePage_patesState extends State<HomePage_pates> {
  @override
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkIfAdmin();
  }

  Future<void> checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('user').doc(user.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }

  Future<List<Article>> fetchArticles() async {
    List<Article> allArticles = [];
    List<String> collections = ['Pâtes & dérivés']; // Tes gammes ici

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
      appBar: AppBar(title: Text('Pâtes & dérivés')),
      body: FutureBuilder<List<Article>>(
        future: fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                  gradient: LinearGradient(colors: [Color(0xffB81736), Color(0xff281537)]),
                ),
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Align(
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    color: Colors.white,
                  ),
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Text(
                        "LES PRODUITS DE BOUTIQUE",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return ListTile(
                              leading: Image.network(article.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(article.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${article.price} FCFA'),
                                  Text('Stock : ${article.Stocks}'),
                                  if (article.collectionName != null)
                                    Text('Gamme : ${article.collectionName}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(pageBuilder: (_,__,___)=>ArticleDetailsPage(article: article),)

                                );
                              },
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
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_circle),
            label: "Ajouter",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddArticlePage()));
            },
          ),

          SpeedDialChild(
            child: Icon(Icons.navigate_next_rounded),
            label: "Navigation",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => test_navigations()));
            },
          ),
        ],
      )
          : null,
    );
  }
}


