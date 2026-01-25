import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

import 'navigations.dart';

class MapPage extends StatefulWidget
{
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage>
{
  final phoneController = TextEditingController();
  final nomController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();

  late LatLng poosition = LatLng(48.8584, 2.2945);
  late LatLng clientPosition = LatLng(48.8619, 2.3314);
  late List<LatLng> routePoints = [];
  late MapController mapController;
  String address = "Adresse du livreur";

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    obtenir_Permission_Location();
  }

  Future<void> obtenir_Permission_Location() async
  {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission refusée. Activez la localisation."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async
  {
    try
    {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        poosition = LatLng(position.latitude, position.longitude);
      });
      mapController.move(poosition, 15.0);
      _getAddress(poosition.latitude,poosition.longitude);
      _getRoute( poosition, clientPosition);
    } catch (e) {
      print('Erreur localisation : $e');
    }
  }

  Future<void> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        address = "Adresse introuvable";
      });
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints = route.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
      });
    } else {
      print("Erreur lors de la récupération de l'itinéraire.");
    }
  }

  void _addClientAddress() async {
    final address = clientAddressController.text.trim();
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        final clientLatLng = LatLng(locations[0].latitude, locations[0].longitude);

        setState(() {
          clientPosition = clientLatLng;
        });

        _getRoute(poosition, clientPosition);
        mapController.move(clientPosition, 15.0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Adresse du client invalide."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _submitAddress() async {
    String addresse = address;
    String phone = phoneController.text;
    String nom = nomController.text;

    if (addresse.isEmpty || phone.isEmpty || nom.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez entrer votre adresse et votre numéro.");
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nom': nom,
        'address': addresse,
        'phone': phone,
        'sendDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    Fluttertoast.showToast(msg: "Adresse et numéro envoyés avec succès.");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => Navigations()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: poosition,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(Icons.location_on, color: Colors.redAccent, size: 40),
            Text("Livreur",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      Marker(
        point: clientPosition,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 40),
            Text("Client",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 5,
          centerTitle: true,
          title: Text(
            "Localisation du Client",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: clientAddressController,
                    decoration: InputDecoration(
                      hintText: "Adresse du client",
                      prefixIcon: Icon(Icons.search, color: Color(0xffB81736)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addClientAddress,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Color(0xffB81736),
                  ),
                  child: Text("Tracer", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: poosition,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=2xnZ3d7WBWgJCdFtjp7g',
                        userAgentPackageName: 'com.example.flutter_map_app',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: poosition,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              Icon(Icons.location_on, color: Color(0xffB81736),
                                  size: 40),
                              Text("Livreur",
                                  style: TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Marker(
                          point: clientPosition,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              Icon(Icons.person_pin_circle,
                                  color: Color(0xff281537), size: 40),
                              Text("Client",
                                  style: TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ]),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.0,
                            color: Color(0xffB81736),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      "© MapTiler © OpenStreetMap contributors",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Formulaire en bas
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone, color: Color(
                              0xffB81736)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: nomController,
                        decoration: InputDecoration(
                          labelText: "Nom",
                          prefixIcon: Icon(Icons.person, color: Color(
                              0xffB81736)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  "📍 $address",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _submitAddress,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      "Envoyer",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )

              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffB81736),
        onPressed: _getCurrentLocation,
        tooltip: "Obtenir la position du livreur",
        child: Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}