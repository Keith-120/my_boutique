import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  TextEditingController _Url = TextEditingController();
  List<String> _collections = ['Haricot', 'articles', 'Chips','Produits secs', 'Divers', 'Épices, condiments & assaisonnements','Pâtes & dérivés','Produits en conserve et sauces'];
  String _selectedCollection = 'Produits en conserve et sauces'; // Valeur par défaut


  Future<void> _addArticle() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tous les champs doivent être remplis")));
      return;
    }

    try {
      // Upload image to Firebase Storage
      // Add article to Firestore
      await FirebaseFirestore.instance.collection(_selectedCollection).add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'Stocks': int.parse(_stockController.text),
        'imageUrl': _Url.text,
        'collectionName': _selectedCollection, // très utile si tu veux réutiliser
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Article ajouté avec succès")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Ajouter un article")),
        body: Stack(
            children: [
              Container(
                height: double
                    .infinity, // ce qui signifie que le conteneur dois  settendre et remplir toute la case de largeur de l ecrant
                width: double
                    .infinity, // ce qui signifie que le conteneur dois  settendre et remplir toute la case de longueur de l ecrant
                decoration: BoxDecoration(
                  gradient: LinearGradient(
// elle va styliser en combinante les couleur
                      colors: [Color(0xffB81736), Color(0xff281537)]),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 10, left: 15),
                  child: Text(
                    "Ajouter des nouveaux \n Article de votre choix  !",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
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
                        color: Colors.white),
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      padding:EdgeInsets.only(top: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Image.asset("assets/images/Image.png"),
                          Padding(padding: EdgeInsets.only(top: 50)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _titleController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Titre",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _descriptionController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Prix',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _Url,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'URL',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SizedBox(
                              width: 300,
                              child: DropdownButtonFormField<String>(
                                value: _selectedCollection,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCollection = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Catégorie',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                items: _collections.map((collection) {
                                  return DropdownMenuItem(
                                    value: collection,
                                    child: Text(collection),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          Padding(padding: EdgeInsets.only(top: 15)),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _addArticle,
                            child: Text("Ajouter l'article"),
                          ),
                        ],
                      ),
                    ),
                  )
              )
            ]));
  }
}
