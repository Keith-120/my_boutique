import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liste_aut/Contenu/Login.dart';
import 'dart:io';
import 'Contenu/interface.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //elle permet d evite le buc en metttant a jour direct 1 fois
  await Firebase.initializeApp(); //elle va connecter notre projet a Firrebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Articles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Interface_app(),
    );
  }
}
