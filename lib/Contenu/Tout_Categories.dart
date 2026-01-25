import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Contenu/Data_recovery.dart';
import 'Home.dart';
import 'Details_article.dart';

class ToutCategorie extends StatelessWidget {
  Future<List<Article>> fetchArticles() async {
    List<Article> allArticles = [];

    List<String> collections = [
      'Haricot',
      'articles',
      'Chips',
      'Produits secs',
      'Divers',
      'Épices, condiments & assaisonnements',
      'Pâtes & dérivés',
      'Produits en conserve et sauces'
    ];

    for (String collection in collections) {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(collection).get();
      List<Article> articles = snapshot.docs
          .map((doc) => Article.fromFirestore(doc, collection))
          .toList();
      allArticles.addAll(articles);
    }

    return allArticles;
  }
  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false;
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
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(40)),
                  ),
                  child: const Padding(
                      padding: EdgeInsets.only(top: 20, left: 22),
                      child:Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              " Sélectionnez \n vos produits préférés !",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      )
                  ),

                ),


                Padding(
                  padding: const EdgeInsets.only(top: 110),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "🛍️ LES PRODUITS DE BOUTIQUE",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),


                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Details_article(article: article),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 6, // ombre plus visible
                                  shadowColor: Colors.grey.withOpacity(0.3),
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [

                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            article.imageUrl,
                                            width: 65,
                                            height: 65,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 14),


                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                article.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${article.Stocks} pièces",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              if (article.collectionName != null)
                                                Text(
                                                  "Gamme : ${article.collectionName}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),


                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${article.price} FCFA",
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

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
