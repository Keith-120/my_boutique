import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liste_aut/Contenu/Pages_Acceuille.dart';
import '../Contenu/Recuperation_Donnees.dart';
import 'Acceuilless.dart';
import 'Detaille_article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Contenu/Recuperation_Donnees.dart';
import 'Detaille_article.dart';
import 'navigationss.dart';
 // Assure-toi d'importer la bonne page d'accueil



class ToutCategorie extends StatelessWidget {
  Future<List<Article>> fetchArticles() async {
    List<Article> allArticles = [];

    List<String> collections = ['Haricot', 'articles', 'Chips','Produits secs', 'Divers', 'Épices, condiments & assaisonnements','Pâtes & dérivés','Produits en conserve et sauces'];

    for (String collection in collections) {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(collection).get();
      List<Article> articles = snapshot.docs.map((doc) {
        return Article.fromFirestore(doc, collection);
      }).toList();
      allArticles.addAll(articles);
    }

    return allArticles;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Remplacer la page actuelle par la navigation principale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Acceuilless(),)
        );
        return false; // Empêche le retour normal
      },
      child: Scaffold(
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
                // 🌄 Décor du haut
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                    ),
                  ),
                  padding: EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Sélectionne tous les produits que vous désirez !",
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
                  padding: const EdgeInsets.only(top: 80),
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
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 15),
                        Expanded(
                          child: ListView.builder(
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return ListTile(
                                leading: Image.network(
                                  article.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(article.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${article.price} FCFA'),
                                    Text('${article.Stocks} Pieces '),
                                    if (article.collectionName != null)
                                      Text('Gamme : ${article.collectionName}',
                                          style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleDetailsPage(article: article),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
