import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class authentification_service
{
  FirebaseAuth _auth = FirebaseAuth.instance;

  //creation de l utilisateur  de l application *******************************************************
  Future<User?> signUpWithEmailAndPassword(
      String Nom,String Email, String Password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
         email: Email, password: Password);
      return credential.user;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "veuillez verifier vos information",
          gravity: ToastGravity.CENTER,
          fontSize: 5);
    }
    return null;
  }

//connexion via login de l application *******************************************************

  Future<User?> signInWithEmailAndPassword(
      String Email, String Password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: Email, password: Password);
      return credential.user;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "veuillez verifier vos information",
          gravity: ToastGravity.CENTER,
          fontSize: 5);
    }
    return null;
  }
}
