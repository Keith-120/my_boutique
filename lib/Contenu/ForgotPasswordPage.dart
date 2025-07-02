import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une adresse e-mail valide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de réinitialisation envoyé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xffB81736), Color(0xff281537)]),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 70, left: 22),
          child: Text(
            "Vous avez \n Oublié votre Mot de passe  !",
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(top: 100)),
                  Image.asset("assets/images/Image.png"),
                  Padding(padding: EdgeInsets.only(top: 50)),
                        Text(
                      'Entrez votre adresse e-mail \n pour recevoir un lien de réinitialisation.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,),

                    Padding(padding: EdgeInsets.only(top: 15)),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child:
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Adresse e-mail',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 70,
                    ),
                    _isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        child: Text('Envoyer'),
                      ),
                    ),
                    ]
                    )
                  ),

          ),
            ),

    ]));
  }
}
