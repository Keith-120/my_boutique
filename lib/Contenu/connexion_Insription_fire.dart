

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthentificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User?> signUpWithEmailAndPassword(
      String nom, String email, String password, String phoneNumber) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {

        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "nom": nom,
          "email": email,
          "phone": phoneNumber,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur inscription : ${e.toString()}",
        gravity: ToastGravity.CENTER,
        fontSize: 14,
      );
    }
    return null;
  }

  //  Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    }
    catch (e) {
      Fluttertoast.showToast(
        msg: "Vérifiez vos informations : ${e.toString()}",
        gravity: ToastGravity.CENTER,
        fontSize: 14,
      );
    }
    return null;
  }
}
