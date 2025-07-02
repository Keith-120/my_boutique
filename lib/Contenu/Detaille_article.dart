import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liste_aut/Contenu/Creation_compte.dart';
import 'package:liste_aut/Contenu/Login.dart';
import 'package:liste_aut/Contenu/Recuperation_Donnees.dart';

class ArticleDetailsPage extends StatefulWidget {
  final Article article;

  ArticleDetailsPage({required this.article, Key? key}) : super(key: key);

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  final _quantiteController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  List<String> collections = ['Haricot', 'articles', 'Chips','Produits secs', 'Divers', 'Épices, condiments & assaisonnements','Pâtes & dérivés','Produits en conserve et sauces'];

  bool _isAdmin = false;
  String? _userRole;
  String? selectedUserId; // Utilisé par l'admin pour consulter un utilisateur

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.article.title;
    _priceController.text = widget.article.price.toString();
    _stockController.text = widget.article.Stocks.toString();
    checkIfAdmin();
  }

  void checkIfAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
  }

  void addToCart(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connexion requise'),
          content: Text('Vous devez vous connecter ou créer un compte pour ajouter un article au panier.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ecranlogin()));
              },
              child: Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => Creation_Compte()));
              },
              child: Text('Créer un compte'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        ),
      );
      return;
    }

    final quantiteText = _quantiteController.text.trim();
    final quantite = double.tryParse(quantiteText);

    if (quantite == null || quantite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantité invalide')),
      );
      return;
    }

    final stockDispo = widget.article.Stocks.toDouble();
    print("Quantité demandée: $quantite / Stock dispo: $stockDispo");

    if (quantite <= stockDispo) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add({
        'articleId': widget.article.id,
        'title': widget.article.title,
        'description': widget.article.description,
        'Stocks': widget.article.Stocks,
        'Quantite': quantite,
        'price': widget.article.price * quantite,
        'imageUrl': widget.article.imageUrl,
        'collection': widget.article.collectionName ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.article.title} ajouté au panier')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock insuffisant')),
      );
    }
  }


  void updateProduct() async {
    final newTitle = _titleController.text;
    final newPrice = double.tryParse(_priceController.text);
    final newStock = int.tryParse(_stockController.text);

    if (newTitle.isEmpty || newPrice == null || newStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Champs invalides")),
      );
      return;
    }

    final collection = widget.article.collectionName;

    if (collection == null || collection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Collection introuvable pour ce produit.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(collection) // ✅ Dynamique
          .doc(widget.article.id)
          .update({
        'title': newTitle,
        'price': newPrice,
        'stock': newStock,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produit mis à jour")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Image.network(widget.article.imageUrl, height: 300),
          const SizedBox(height: 20),

          // Affichage pour tout utilisateur
          TextField(
            controller: _quantiteController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "Quantité",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                )),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => addToCart(context),
            child: Text('Ajouter au panier'),
          ),

          // Champs supplémentaires si admin
          if (_userRole == 'admin') ...[
            const Divider(height: 40),
            Text("Modifier le produit (admin)", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: "Prix",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: "Stock",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  )),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,
              child: Text("Mettre à jour"),
            ),
          ]
        ]),
      ),
    );
  }
}
