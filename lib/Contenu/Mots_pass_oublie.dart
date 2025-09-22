import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mots_pass_oublie extends StatefulWidget {
  @override
  Mots_pass_oublieState createState() => Mots_pass_oublieState();
}

class Mots_pass_oublieState extends State<Mots_pass_oublie> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Utiliser la langue française pour les emails envoyés par Firebase
    _auth.setLanguageCode('fr');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    // Vérification avec regex plutôt que contains('@')
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnack('Veuillez entrer une adresse e-mail valide.', error: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnack(
        "Si un compte existe pour cet e-mail, un lien de réinitialisation a été envoyé. Vérifiez aussi le dossier SPAM.",
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "Adresse e-mail invalide.";
          break;
        case 'missing-email':
          message = "Veuillez saisir votre e-mail.";
          break;
        case 'too-many-requests':
          message = "Trop de tentatives. Réessayez plus tard.";
          break;
        case 'network-request-failed':
          message = "Problème de connexion Internet.";
          break;
        case 'operation-not-allowed':
          message = "La connexion Email/Mot de passe est désactivée dans Firebase.";
          break;
        default:
          message = "Erreur: ${e.message ?? e.code}";
      }
      _showSnack(message, error: true);
    } catch (e) {
      _showSnack('Erreur inattendue: $e', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dégradé
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xffB81736), Color(0xff281537)]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 70, left: 22),
              child: Text(
                "Vous avez \noublié votre mot de passe ?",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Image.asset("assets/images/Image.png"),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Champ email
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _resetPassword(),
                        decoration: InputDecoration(
                          labelText: 'Adresse e-mail',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton envoyer
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      height: 50,
                      width: 180,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff281537),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        ),
                        onPressed: _resetPassword,
                        child: const Text('Envoyer', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton retour
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("← Retour à la connexion", style: TextStyle(color: Colors.black54)),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
