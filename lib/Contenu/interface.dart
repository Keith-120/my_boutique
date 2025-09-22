import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:liste_aut/Contenu/navigations.dart';
import 'Creation_Compte.dart';
import 'Login.dart';

class InterfaceApp extends StatelessWidget {
  const InterfaceApp({super.key});


  Future<void> cree_utilisateur(User user, {String? phone, String? name}) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'nom': name ?? user.displayName ?? 'Utilisateur',
        'email': user.email ?? '',
        'phone': phone ?? '',
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }


  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Annulé par l'utilisateur

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await cree_utilisateur(user, name: user.displayName);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Navigations()),
        );
      }
    } catch (e) {
      debugPrint("Erreur Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google Sign-In: $e"), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        String name =
        credential.givenName != null ? '${credential.givenName} ${credential.familyName}' : user.displayName ?? 'Utilisateur';
        await cree_utilisateur(user, name: name);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Navigations()),
        );
      }
    } catch (e) {
      debugPrint("Erreur Apple Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Apple Sign-In: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 🔹 Connexion Facebook
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        final credential = FacebookAuthProvider.credential(accessToken);

        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final userData = await FacebookAuth.instance.getUserData();
          await cree_utilisateur(user, name: userData['name']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Navigations()),
          );
        }
      } else {
        debugPrint("Facebook login annulé : ${result.status}");
      }
    } catch (e) {
      debugPrint("Erreur Facebook Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Facebook Sign-In: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffB81736), Color(0xff281537)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage("assets/images/shop.png"),
              ),
              const SizedBox(height: 20),
              const Text(
                "VENTE D'ARTICLES",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Des soldes incroyables pour des clients incroyables 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 80),

              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ecranlogin()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xffB81736),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Creation_Compte()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff281537),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 250,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Navigations()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Commencer sans se connecter",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Colors.white54,
                      thickness: 1,
                      indent: 40,
                      endIndent: 10,
                    ),
                  ),
                  Text(
                    "Ou continuer avec",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white54,
                      thickness: 1,
                      indent: 10,
                      endIndent: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton("assets/images/270014.png",
                          () => signInWithGoogle(context)),
                  const SizedBox(width: 20),
                  _socialButton("assets/images/iOS.jpg",
                          () => signInWithApple(context)),
                  const SizedBox(width: 20),
                  _socialButton("assets/images/3665141.png",
                          () => _signInWithFacebook(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _socialButton(String asset, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: Image.asset(asset, height: 25),
      ),
    );
  }
}
