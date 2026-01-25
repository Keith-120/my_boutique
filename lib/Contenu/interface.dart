import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liste_aut/Contenu/navigations.dart';
import 'Creation_Compte.dart';
import 'Login.dart';

class InterfaceApp extends StatefulWidget
{
  const InterfaceApp({super.key});

  @override
  State<InterfaceApp> createState() => _InterfaceAppState();
}

class _InterfaceAppState extends State<InterfaceApp>
    with SingleTickerProviderStateMixin

{
  late AnimationController controlleur_;
  late Animation<double> fadeAnimation_;

  @override
  void initState() {
    super.initState();

    controlleur_ = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fadeAnimation_ = CurvedAnimation(
      parent: controlleur_,
      curve: Curves.easeInOut,
    );

    controlleur_.forward();
  }

  @override
  void dispose() {
    controlleur_.dispose();
    super.dispose();
  }


  Future<void> cree_Utilisateur(User user, {String? phone, String? name}) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('user') 
        .doc(user.uid);

    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
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
      final googleUser_ = await GoogleSignIn().signIn();
      if (googleUser_ == null) return;

      final googleAuth = await googleUser_.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await cree_Utilisateur(user, name: user.displayName);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Navigations()));
      }
    }
    catch (e)
    {
      debugPrint("Erreur Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google Sign-In: $e"), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> signInWithApple(BuildContext context) async
  {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        String name = credential.givenName != null
            ? '${credential.givenName} ${credential.familyName}'
            : user.displayName ?? 'Utilisateur';
        await cree_Utilisateur(user, name: name);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Navigations()));
      }
    } catch (e) {
      debugPrint("Erreur Apple Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Apple Sign-In: $e"), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> signInWithFacebook(BuildContext context) async
  {
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
          await cree_Utilisateur(user, name: userData['name']);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Navigations()));
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
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: fadeAnimation_,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "🛍️ Bienvenue dans la boutique en ligne",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Des soldes incroyables pour des clients incroyables 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                Connexion_(
                  label: "Se connecter",
                  bgColor: const Color(0xffB81736),
                  textColor: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ecranlogin()),
                  ),
                ),
                const SizedBox(height: 16),

                Connexion_(
                  label: "Créer un compte",
                  bgColor: const Color(0xff281537),
                  textColor: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Creation_Compte()),
                  ),
                ),
                const SizedBox(height: 16),

                _customOutlinedButton(
                  label: "Continuer sans se connecter",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Navigations()),
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  children: const [
                    Expanded(
                      child: Divider(thickness: 1, indent: 30, endIndent: 10),
                    ),
                    Text(
                      "Ou continuer avec",
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, indent: 10, endIndent: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button_Connexion(
                        "assets/images/270014.png",
                            () => signInWithGoogle(context)),
                    const SizedBox(width: 20),
                    Button_Connexion(
                        "assets/images/iOS.jpg",
                            () => signInWithApple(context)),
                    const SizedBox(width: 20),
                    Button_Connexion(
                        "assets/images/3665141.png",
                            () => signInWithFacebook(context)),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets personnalisés ---
  static Widget Connexion_({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }

  static Widget _customOutlinedButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffB81736), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xffB81736),
          ),
        ),
      ),
    );
  }

  static Widget Button_Connexion (String asset, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Image.asset(asset, height: 26),
      ),
    );
  }
}

