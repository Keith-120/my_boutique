import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Page_Ajout_article extends StatefulWidget {
  @override
  Page_Ajout_articleState createState() => Page_Ajout_articleState();
}

class Page_Ajout_articleState extends State<Page_Ajout_article> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final urlController = TextEditingController();
  final stockController = TextEditingController();

  final List<String> _collections = [
    'Haricot',
    'Produits secs',
    'Divers',
    'Épices, condiments & assaisonnements',
    'Pâtes & dérivés',
    'Produits en conserve et sauces',
  ];

  String _selectedCollection = 'Haricot';
  bool _isLoading = false;

  Future<void> _addArticle() async {
    String title = titleController.text.trim();
    String priceText = priceController.text.trim();
    String stockText = stockController.text.trim();
    String imageUrl = urlController.text.trim();

    if (title.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Tous les champs doivent être remplis")),
      );
      return;
    }


    double? price = double.tryParse(priceText);
    int? Stocks = int.tryParse(stockText);

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Entrez un prix valide")),
      );
      return;
    }
    if (Stocks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Entrez un stock valide")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection(_selectedCollection).add({
        'title': title,
        'price': price,
        'Stocks': Stocks,
        'imageUrl': imageUrl,
        'collectionName': _selectedCollection,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Article ajouté avec succès")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
        Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius:
          const BorderRadius.only(bottomLeft: Radius.circular(40)),
        ),
        child: const Padding(
            padding: EdgeInsets.only(top: 50, left: 22),
            child:Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ajouter \n vos articles  ",
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
            padding: const EdgeInsets.only(top: 140),
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
                    Image.asset("assets/images/Image.png", height: 100),
                    SizedBox(height: 15),
                    Text(
                      "Ajoutez un article rapidement",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),


                    _buildTextField(titleController, "Titre",
                        icon: Icons.article),
                    SizedBox(height: 15),
                    _buildTextField(urlController, "URL de l'image",
                        icon: Icons.image),
                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(priceController, "Prix",
                              inputType: TextInputType.number,
                              icon: Icons.attach_money),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(stockController, "Stocks",
                              inputType: TextInputType.number,
                              icon: Icons.storage),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedCollection,
                      onChanged: (value) =>
                          setState(() => _selectedCollection = value!),
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: Icon(Icons.category),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _collections.map((collection) {
                        return DropdownMenuItem(
                          value: collection,
                          child: Text(
                            collection,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        );
                      }).toList(),
                    ),


                    SizedBox(height: 30),

                    // Bouton Ajouter
                    SizedBox(
                      width: 200,
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
                          onPressed: _isLoading ? null : _addArticle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Ajouter",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ]
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
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
      ),
    );
  }
}
