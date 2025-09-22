import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liste_aut/boîtes à pizza/Article.dart';

import '../Contenu/Creation_Compte.dart';
import '../Contenu/Login.dart';


  class ArticleDetailsPage extends StatefulWidget
  {
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

    bool _isAdmin = false;
    String? _userRole;
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
          });
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ecranlogin())),
                child: Text('Se connecter'),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Creation_Compte())),
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
      if (quantite > stockDispo) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock insuffisant')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart_temp')
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l’ajout au panier : $e')),
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
            .collection(collection)
            .doc(widget.article.id)
            .update({
          'title': newTitle,
          'price': newPrice,
          'Stocks': newStock,
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.article.title),

        ),
        body: Stack(
          children: [
            // Dégradé en arrière-plan
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffB81736), Color(0xff281537)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image produit
                      Image.network(widget.article.imageUrl, height: 250),
                      SizedBox(height: 20),
                      Text(widget.article.title,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("${widget.article.price} FCFA",
                          style: TextStyle(fontSize: 18, color: Colors.black54)),
                      SizedBox(height: 10),
                      Text("Stock disponible : ${widget.article.Stocks}",
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),

                      SizedBox(height: 20),
                      // Quantité
                      _buildTextField(_quantiteController, "Quantité", icon: Icons.confirmation_num),
                      SizedBox(height: 15),
                      _buildButton("Ajouter au panier", addToCart),

                      SizedBox(height: 20),

                      // Admin update
                      if (_userRole == 'admin') ...[
                        Divider(height: 40),
                        Text("Modifier le produit (admin)",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildTextField(_titleController, "Titre", icon: Icons.article),
                        SizedBox(height: 10),
                        _buildTextField(_priceController, "Prix", inputType: TextInputType.number, icon: Icons.attach_money),
                        SizedBox(height: 10),
                        _buildTextField(_stockController, "Stock", inputType: TextInputType.number, icon: Icons.storage),
                        SizedBox(height: 15),
                        _buildButton("Mettre à jour", (_) => updateProduct()),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildTextField(TextEditingController controller, String label,
        {TextInputType inputType = TextInputType.text, IconData? icon}) {
      return TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    }

    Widget _buildButton(String text, Function(BuildContext) onPressed) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffB81736), Color(0xff281537)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ElevatedButton(
            onPressed: () => onPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      );
    }
  }
