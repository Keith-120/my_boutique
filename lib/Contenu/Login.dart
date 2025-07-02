import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liste_aut/Contenu/paiement_paypal.dart';

import 'Article_Panier_.dart';
import 'Creation_compte.dart';
import 'ForgotPasswordPage.dart';
import 'connexion_Insription_fire.dart';
import 'map_pages.dart';
import 'navigationss.dart';

class  ecranlogin extends StatefulWidget {
  const ecranlogin({super.key});

  @override
  State<ecranlogin> createState() => _ecranloginState();
}

class _ecranloginState extends State<ecranlogin> {
  bool isloading = false;
  int _failedAttempts = 0;
  String _verificationId = '';
  TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isObscure = true;
  final authentification_service _auth = authentification_service();
  String _loginMethod = 'email'; // email ou telephone
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _Password = TextEditingController();

  void dispose() {
    _email.dispose();
    _Password.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              height: double
                  .infinity,
              // ce qui signifie que le conteneur dois  settendre et remplir toute la case de largeur de l ecrant
              width: double
                  .infinity,
              // ce qui signifie que le conteneur dois  settendre et remplir toute la case de longueur de l ecrant
              decoration: BoxDecoration(
                gradient: LinearGradient(
// elle va styliser en combinante les couleur
                    colors: [Color(0xffB81736), Color(0xff281537)]),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 70, left: 22),
                child: Text(
                  "Salue\nConnecter Vous !",
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
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 15)),
                        Image.asset("assets/images/Image.png"),
                        Padding(padding: EdgeInsets.only(top: 25)),
                        SizedBox(
                          width: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Connexion via: ", style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),),
                              DropdownButton<String>(
                                value: _loginMethod,
                                items: [
                                  DropdownMenuItem(
                                      value: 'email', child: Text('Email')),
                                  DropdownMenuItem(
                                      value: 'telephone',
                                      child: Text('Téléphone')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _loginMethod = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: _loginMethod == 'email'
                              ? TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              label: Text("Email"),
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(20)),
                              suffixIcon: Icon(Icons.email),
                            ),
                          )
                              : TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              label: Text("Numéro de téléphone"),
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(20)),
                              suffixIcon: Icon(Icons.phone),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 38)),
                        SizedBox(
                            width: 300,
                            child: TextField(
                                controller: _Password,
                                obscureText: _isObscure,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Password",
                                    style:
                                    TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ))),
                        /*  Align(
                        alignment: Alignment.center,
                        child:Text('veuillez entre le mots de pass'),
                      ),
                      */
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartPage(),
                          ),
                        );

                      },
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                              ForgotPasswordPage()));
                                },
                                child: Text(
                                  "mots de passe oublie ",
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 50,
                          width: 150,
                          child: Container(
                            child: isloading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: () {
                                if (_loginMethod == 'email') {
                                  _signin();
                                } else {
                                  _loginWithPhone();
                                }
                              },
                              child: Text("envoyer"),
                            ),

                          ),
                        ),

                        if (_loginMethod == 'telephone' && _otpSent)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Code SMS",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _verifyOTP,
                                  child: Text("Vérifier le code"),
                                ),
                              ],
                            ),
                          ),


                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          //alignment: Alignment.bottomRight,
                          child: Container(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("vous n avez pas de compte"),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  Creation_Compte()));
                                    },
                                    child: Text(
                                      "cree un compte ",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            ),
                          ),

                        )

                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _signin() async {
    String email = _email.text.trim();
    String password = _Password.text.trim();
    bool isValidEmail(String email) {
      return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email);
    }
    if (!isValidEmail(email)) {
      Fluttertoast.showToast(msg: "Email invalide");
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: "Mot de passe trop court");
      return;
    }

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Fluttertoast.showToast(
              msg: "Email non vérifié. Un lien a été envoyé.",
              gravity: ToastGravity.CENTER);
          return;
        }

        // ➕ Ici tu peux récupérer son rôle Firestore si tu veux
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => test_navigations()),
              (route) => false,
        );
        Fluttertoast.showToast(msg: "Connecté avec succès");
      }
    } catch (e) {
  _failedAttempts++;
  if (_failedAttempts >= 5) {
  Fluttertoast.showToast(msg: "Trop de tentatives. Réessayez plus tard.");
  return;
  }
  Fluttertoast.showToast(
  msg: "Erreur de connexion (${_failedAttempts}/5) : ${e.toString()}");
  }

  }


  void _verifyOTP() async {
    String smsCode = _otpController.text.trim();
    if (smsCode.isEmpty) {
      Fluttertoast.showToast(msg: "Entrez le code reçu par SMS.");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(
        context,
        PageRouteBuilder(pageBuilder: (_, __, ___) => test_navigations()),
      );
      Fluttertoast.showToast(msg: "Connexion réussie !");
    } catch (e) {
      Fluttertoast.showToast(msg: "Code invalide ou expiré.");
    }
  }

  void _loginWithPhone() async {
    String phone = _phone.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un numéro de téléphone",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() {
      isloading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Connexion automatique sans OTP (si Android détecte le code automatiquement)
        setState(() {
          isloading = false;
        });

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => test_navigations()),
        );
        Fluttertoast.showToast(msg: "Connecté automatiquement !");
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isloading = false;
        });

        Fluttertoast.showToast(
          msg: "Erreur: ${e.message}",
          gravity: ToastGravity.CENTER,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // ✅ Attendre saisie manuelle de l'OTP
        setState(() {
          isloading = false;
          _otpSent = true;
          _verificationId = verificationId;
        });

        Fluttertoast.showToast(
          msg: "Code envoyé. Veuillez entrer le code SMS.",
          gravity: ToastGravity.CENTER,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }
}