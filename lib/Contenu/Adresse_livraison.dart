import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class AdresseLivraisonPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String paiementId;

  const AdresseLivraisonPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.paiementId,
  });

  @override
  AdresseLivraisonPageState createState() => AdresseLivraisonPageState();
}

class AdresseLivraisonPageState extends State<AdresseLivraisonPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();

  late LatLng clientPosition;
  late LatLng livreurPosition = LatLng(48.8584, 2.2945);

  late MapController mapController;
  late List<LatLng> routePoints = [];

  String detectedAddress = "Détection de votre adresse...";

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    clientPosition = LatLng(widget.latitude, widget.longitude);

    _convertCoordinatesToAddress(widget.latitude, widget.longitude);
    obtenirPermissionLocation();
  }

  Future<void> obtenirPermissionLocation() async {
    var status = await Permission.location.request();
    if (!status.isGranted) return;
    _getLivreurCurrentLocation();
  }

  Future<void> _getLivreurCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        livreurPosition = LatLng(pos.latitude, pos.longitude);
      });

      mapController.move(clientPosition, 15);
      _getRoute(livreurPosition, clientPosition);

    } catch (e) {
      print("Erreur localisation livreur : $e");
    }
  }

  Future<void> _convertCoordinatesToAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark p = placemarks[0];

      setState(() {
        detectedAddress =
        "${p.street}, ${p.locality}, ${p.postalCode}, ${p.country}";
        clientAddressController.text = detectedAddress;
      });
    } catch (e) {
      setState(() => detectedAddress = "Adresse introuvable");
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final coords = json['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints = coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
      });
    }
  }


  Future<void> _saveClientAddress() async {
    final phone = phoneController.text.trim();
    final nom = nomController.text.trim();
    final adresse = clientAddressController.text.trim();

    if (phone.isEmpty || nom.isEmpty || adresse.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez remplir tous les champs.");
      return;
    }

    await FirebaseFirestore.instance
        .collection("commandes")
        .doc(widget.paiementId)
        .update({
      "client_position": {
        "lat": clientPosition.latitude,
        "lng": clientPosition.longitude,
        "address": adresse,
        "nom": nom,
        "phone": phone,
      }
    });

    Fluttertoast.showToast(
        msg: "Adresse enregistrée avec succès",
        backgroundColor: Colors.green);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: livreurPosition,
        width: 80,
        height: 80,
        child: Column(
          children: const [
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
          children: const [
            Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 40),
            Text("Moi (client)",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirmer l’adresse",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffB81736), Color(0xff281537)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: clientAddressController,
                    decoration: InputDecoration(
                      labelText: "Votre adresse",
                      prefixIcon:
                      const Icon(Icons.home, color: Color(0xffB81736)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: clientPosition,
                  zoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=2xnZ3d7WBWgJCdFtjp7g",
                  ),
                  MarkerLayer(markers: markers),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4,
                        color: const Color(0xffB81736),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: const Icon(Icons.phone,
                              color: Color(0xffB81736)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: nomController,
                        decoration: InputDecoration(
                          labelText: "Nom",
                          prefixIcon: const Icon(Icons.person,
                              color: Color(0xffB81736)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  "📍 Adresse détectée :\n$detectedAddress",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),


                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveClientAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                    ),
                    child: const Text(
                      "Confirmer mon adresse",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
