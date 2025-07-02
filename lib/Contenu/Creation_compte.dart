import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liste_aut/Contenu/Article_Panier_.dart';
import 'package:liste_aut/Contenu/navigationss.dart';
import 'package:liste_aut/Contenu/paiement_paypal.dart';
import 'connexion_Insription_fire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Creation_Compte extends StatefulWidget {
  const Creation_Compte({super.key});

  @override
  State<Creation_Compte> createState() => _Creation_CompteState();
}

class _Creation_CompteState extends State<Creation_Compte> {
  bool  _isObscure = true ;
  bool  _isObscures = true ;
  final authentification_service auth_ = authentification_service();
  TextEditingController _telephone = TextEditingController();
  TextEditingController _Nom = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();


  void dispose() {
    _telephone.dispose();
    _Nom.dispose();

    _email.dispose;
    _password.dispose;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffB81736), Color(0xff281537)]),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 70, left: 22),
              child: Text(
                "Salue\n Veuillez cree un compte !",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Image.asset("assets/images/Image.png"),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _Nom,
                        decoration: InputDecoration(
                          label: Text(
                            "Nom",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          suffixIcon: Icon(Icons.account_box_rounded),
                        ),
                      ),
                    ),

                    Padding(padding: EdgeInsets.only(top: 38)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                          controller: _email,
                          decoration: InputDecoration(
                              label: Text(
                                "Gmail",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              suffixIcon: Icon(Icons.email))),
                    ),
                    Padding(padding: EdgeInsets.only(top: 38)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _telephone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          label: Text(
                            "Numéro de téléphone",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          suffixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),

                    Padding(padding: EdgeInsets.only(top: 38)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                          controller: _password,
                          obscureText:  _isObscure,
                          decoration: InputDecoration(
                              label: Text(
                                "Mots de passe",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure =  !_isObscure ;
                                  });
                                },
                              )
                    ),
                      ),
                    ),

                    Padding(padding: EdgeInsets.only(top: 38)),
                    SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: inscription,
                          child: Text("envoyer",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold)),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void inscription() async {
    String Nom = _Nom.text;
    String email = _email.text;
    String password = _password.text;
    String telephone = _telephone.text;

    // Vérifie si l'email correspond à un administrateur (exemple pour un email spécifique)
    String role = "client"; // Par défaut, le rôle est "client"
    User? user = await auth_.signUpWithEmailAndPassword(
        Nom, email, password);

    if (user != null) {
      // Une fois que l'utilisateur est créé, on l'ajoute à Firestore avec son rôle  collection('cart')
      //             .add({
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('user').doc(user.uid).set({
        'nom': Nom,
        'email': email,
        'telephone': telephone, // nouveau champ
        'role': role,
      });

      print("Utilisateur connecté à : ${user.email}");
      Navigator.push(
        context, PageRouteBuilder(pageBuilder: (_, __, ___) => CartPage()),
      );
      Fluttertoast.showToast(msg: "Inscription réussie avec succès", gravity: ToastGravity.CENTER);
    } else {
      print("Erreur de connexion ");
      Fluttertoast.showToast(msg: "Veuillez saisir les données correctement", gravity: ToastGravity.CENTER);
    }
  }
}
