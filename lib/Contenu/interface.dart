
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liste_aut/Contenu/Acceuilless.dart';
import 'package:liste_aut/Contenu/navigationss.dart';
import 'Creation_compte.dart';
import 'Login.dart';

class Interface_app extends StatelessWidget {
  const Interface_app({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xffB81736), Color(0xff281537)]),),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 120)),
Container(
  width: 600,
  height: 300,
  child:
      CircleAvatar(
        backgroundImage:
        AssetImage("assets/images/pngtree-electronic-consumer-studio-photography-laptop-shopping-cart-cardboard-box-online-shopping-image_853469.jpg"),

      )

),
                  Padding(padding: EdgeInsets.only(top: 30)),
                Text("VENTE D'ARTICLES ", style:
                TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold, color: Colors.white,
                  fontSize: 25,
                ),),
                Padding(padding: EdgeInsets.only(top: 100)),
                Text("Venez faire des economie! c est l heure des Solde ! \n les soldes incroyable pour des client incroyable", style:
                TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white
                ),),
                Padding(padding: EdgeInsets.only(top: 50)),
                Text("Clique et commencer cette aventure ",style:
                    TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white),),
                    Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => test_navigations()));
              },
              child: Text(
                "Commencer",
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
                Padding(padding: EdgeInsets.only(top: 190)),
              ],
            ),
          ),

        ),

      ),

    );
  }


}
