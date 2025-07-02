import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final double price;
  final int Stocks;
  final String imageUrl;
  String? collectionName;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.Stocks,
    required this.imageUrl,
    this.collectionName, // Corrigé ici
  });

  factory Article.fromFirestore(DocumentSnapshot doc, String collectionName) {
    final data = doc.data() as Map<String, dynamic>;

    return Article(
      id: doc.id,
      title: data['title'] ?? 'Sans titre',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      Stocks: data['Stocks'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      collectionName: collectionName,
    );
  }
}

