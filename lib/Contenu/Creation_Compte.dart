import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Creation_Compte extends StatefulWidget {
  const Creation_Compte({super.key});

  @override
  State<Creation_Compte> createState() => _Creation_CompteState();
}

class _Creation_CompteState extends State<Creation_Compte> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;


  Future<void> _creerCompte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 🔍 Vérifier si le téléphone existe déjà
      final phoneCheck = await FirebaseFirestore.instance
          .collection("users")
          .get();

      bool phoneExists = phoneCheck.docs.any(
            (doc) => doc.data().containsKey("phone") &&
            doc["phone"] == _phoneController.text.trim(),
      );

      if (phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ce numéro de téléphone est déjà utilisé ")),
        );
        setState(() => _isLoading = false);
        return;
      }


      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("user")
            .doc(user.uid)
            .set({
          "uid": user.uid,
          "nom": _nomController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "role": "client", // 🔹 par défaut
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès ✅")),
        );

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = "Cet email est déjà utilisé ";
      } else if (e.code == 'weak-password') {
        message = "Mot de passe trop faible ";
      } else {
        message = "Erreur : ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 70, left: 22),
              child: Text(
                "Salut 👋\n Créez votre compte !",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(top: 170),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/images/Image.png", height: 80),
                      const SizedBox(height: 30),


                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(
                            labelText: "Nom",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? "Entrez votre nom" : null,
                        ),
                      ),
                      const SizedBox(height: 15),


                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Téléphone",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Entrez votre numéro de téléphone"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),


                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) => value == null || !value.contains("@")
                              ? "Entrez un email valide"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),


                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isObscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() => _isObscure = !_isObscure);
                              },
                            ),
                          ),
                          validator: (value) => value == null || value.length < 6
                              ? "Mot de passe trop court (min 6 caractères)"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 30),

                      const SizedBox(height: 30),

                      // Bouton Créer
                      // Bouton Créer avec dégradé identique au header
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xffB81736), Color(0xff281537)], // 🔥 même dégradé
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _creerCompte,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // important pour voir le dégradé
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Créer mon compte",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
