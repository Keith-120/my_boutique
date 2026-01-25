import 'dart:async';
import 'package:flutter/material.dart';
import 'package:liste_aut/Contenu/Pages_Acceuille.dart';
import 'package:liste_aut/Produits en conserve et sauces/HomePage_Produit_conserve.dart';
import '../Divers/HomePage_Divers.dart';
import '../Epices, condiments & assaisonnements/HomePage_Epices.dart';
import '../Pates & dérives/HomePage_pates.dart';
import '../Riz/HomePage_Riz.dart';

class Home extends StatefulWidget
{
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

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

  final List<String> images = [
    'assets/images/IMG-20250214-WA0084.jpg',
    'assets/images/pngtree-electronic-consumer-studio-photography-laptop-shopping-cart-cardboard-box-online-shopping-image_853469.jpg',
    'assets/images/stock-photo-concept-online-sopping-boxes-and-shopping-bag-with-smartphone-online-shopping-screen-1786435313.jpg',
    'assets/images/IMG-20250214-WA0088.jpg',
    'assets/images/IMG-20250214-WA0087.jpg'
  ];

  final LinearGradient appGradient = const LinearGradient(
    colors: [Color(0xffB81736), Color(0xff281537)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  int _currentPage = 0;
  late Timer _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= images.length) _currentPage = 0;

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double searchWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
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
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bienvenue 👋\nExplorez nos meilleures offres",
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
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
            ),

            sectionTitle(""),
            avatarGallery([
              'assets/images/IMG-20250214-WA0084.jpg',
              'assets/images/IMG-20250214-WA0087.jpg',
              'assets/images/IMG-20250214-WA0088.jpg',
              'assets/images/pngtree-electronic-consumer-studio-photography-laptop-shopping-cart-cardboard-box-online-shopping-image_853469.jpg',
              'assets/images/IMG-20250214-WA0084.jpg',
              'assets/images/IMG-20250214-WA0087.jpg',
            ]),


            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: ShaderMask(
                    shaderCallback: (bounds) =>
                        appGradient.createShader(bounds),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  hintText: "Rechercher un produit...",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),


            sectionTitle("Nos Produits populaires"),
            Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 0.0;
                          if (_pageController.hasClients &&
                              _pageController.page != null) {
                            value = (_pageController.page! - index);
                          }
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(value * 0.7),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: (1 - value.abs()).clamp(0.3, 1.0),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    bool isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 22 : 8,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [Color(0xffB81736), Color(0xff281537)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isActive ? null : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ],
            ),


            sectionTitle("Catégories de produits"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1,
                children: [
                  categorieCard(
                      "Haricot",
                      "assets/images/IMG-20250214-WA0087.jpg",
                      "Haricots secs", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HomePage()));
                  }),
                  categorieCard("Produits en conserve et sauces",
                      "assets/images/IMG-20250214-WA0085.jpg", "Conserves", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomePage_Produit_conserve()));
                  }),
                  categorieCard("Riz", "assets/images/IMG-20250214-WA0085.jpg",
                      "Riz parfumé", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomePage_Riz()));
                  }),
                  categorieCard(
                      "Pâtes & dérivés",
                      "assets/images/téléchargement (1).jpeg",
                      "Nos meilleures pâtes", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomePage_pates()));
                  }),
                  categorieCard(
                      "Divers",
                      "assets/images/téléchargement (3).jpeg",
                      "Produits variés", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomePage_Divers()));
                  }),
                  categorieCard(
                      "Épices & assaisonnements",
                      "assets/images/téléchargement.jpeg",
                      "Épices de qualité", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomePage_Epices()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => appGradient.createShader(bounds),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );

  Widget categorieCard(
      String titre, String image, String desc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(image, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            ShaderMask(
              shaderCallback: (bounds) => appGradient.createShader(bounds),
              child: Text(
                titre,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            Text(desc,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget avatarGallery(List<String> images) {
    return SizedBox(
      height: 30,
      child: Align(
        alignment: Alignment.center,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: AssetImage(images[index]),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: images.length,
        ),
      ),
    );
  }
}
