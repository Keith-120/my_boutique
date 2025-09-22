import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Creation_Compte.dart';
import 'Mots_pass_oublie.dart';
import 'connexion_Insription_fire.dart';
import 'navigations.dart';

class ecranlogin extends StatefulWidget {
  const ecranlogin({super.key});

  @override
  State<ecranlogin> createState() => ecranloginState();
}

class ecranloginState extends State<ecranlogin> {
  bool isLoading = false;
  bool isObscure = true;
  final AuthentificationService auth = AuthentificationService();

  TextEditingController _email = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  User? currentUser;

  @override
  void dispose() {
    _email.dispose();
    passwordController.dispose();
    super.dispose();
  }


  Future<void> Chargement_execution(Future<void> Function() task) async {
    setState(() => isLoading = true);
    try {
      await task();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la sortie'),
        content: const Text('Voulez vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            // HEADER
            Column(
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
                      "Salut\n Veuillez vous connecter !",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),


            Padding(
              padding: const EdgeInsets.only(top: 170),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/Image.png"),
                      const SizedBox(height: 25),


                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            suffixIcon: Icon(Icons.email),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),


                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: passwordController,
                          obscureText: isObscure,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            suffixIcon: IconButton(
                              icon: Icon(isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                          ),
                        ),
                      ),


                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Mots_pass_oublie(),
                              ),
                            );
                          },
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),


                      SizedBox(
                        height: 50,
                        width: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xffB81736), Color(0xff281537)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
                              "Connexion",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),


                      Align(
                        child: Column(
                          children: [
                            const Text("Vous n'avez pas de compte ?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => Creation_Compte(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Créer un compte",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        "Patientez...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  void signin() async {
    String email = _email.text.trim();
    String password = passwordController.text.trim();

    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email)) {
      Fluttertoast.showToast(msg: "Email invalide");
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: "Mot de passe trop court");
      return;
    }

    Chargement_execution(() async {
      User? user = await auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        currentUser = user;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Navigations()),
              (route) => false,
        );
        Fluttertoast.showToast(msg: "Connecté avec succès !");
      }
    });
  }
}
