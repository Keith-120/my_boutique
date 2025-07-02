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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _phoneController = TextEditingController();
  final _nomController = TextEditingController();

  void _submitAddress() async {
    String address = _address;
    String phone = _phoneController.text;
    String nom = _nomController.text;
    if (address.isEmpty || phone.isEmpty || nom.isEmpty) {
      Fluttertoast.showToast(
          msg: "Veuillez entrer votre adresse et votre numéro.");
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'nom': nom,
            'address': address,
            'phone': phone,
          },
          SetOptions(
              merge:
                  true)); // Enregistrer l'adresse et le téléphone dans Firestore
    }

    Fluttertoast.showToast(msg: "Adresse et numéro envoyés avec succès.");
    // Retourner à la page du panier ou vers une page de confirmation
    Navigator.pop(context); // Retour à la page précédente
  }

  late LatLng _currentPosition =
      LatLng(48.8584, 2.2945); // Position initiale du livreur
  late LatLng _clientPosition =
      LatLng(48.8619, 2.3314); // Position statique du client
  late List<LatLng> _routePoints = []; // Points pour dessiner l'itinéraire
  late MapController _mapController;
  String _address = "Adresse du livreur";
  final TextEditingController _clientAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLocationPermission();
  }

  // Demander la permission pour la localisation
  Future<void> _getLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Permission refusée. Activez la localisation."),
      ));
    }
  }

  // Obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 15.0);
      _getAddress(_currentPosition.latitude, _currentPosition.longitude);
      _getRoute(_currentPosition, _clientPosition); // Récupérer l'itinéraire
    } catch (e) {
      print('Erreur localisation : $e');
    }
  }

  // Obtenir l'adresse à partir des coordonnées
  Future<void> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _address = "Adresse introuvable";
      });
    }
  }

  // Récupérer l'itinéraire entre le client et le livreur via OSRM
  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        _routePoints =
            route.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
      });
    } else {
      print("Erreur lors de la récupération de l'itinéraire.");
    }
  }

  // Ajouter l'adresse du client
  void _addClientAddress() async {
    final address = _clientAddressController.text.trim();
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        final clientLatLng =
            LatLng(locations[0].latitude, locations[0].longitude);

        setState(() {
          _clientPosition = clientLatLng;
        });

        // Recalculer l'itinéraire avec la nouvelle position du client
        _getRoute(_currentPosition, _clientPosition);
        _mapController.move(_clientPosition, 15.0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Adresse du client invalide."),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      // Marqueur pour la position du livreur
      Marker(
        point: _currentPosition,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 40),
            Text("Livreur", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      // Marqueur pour le client
      Marker(
        point: _clientPosition,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
            Text("Client", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte avec Itinéraire et Marqueur'),
        backgroundColor: Color(701636),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
            SizedBox(
            width:197,
            height: 40,
            child:
            Expanded(
                child: TextField(

                  controller: _clientAddressController,
                  decoration: InputDecoration(
                    hintText: 'Entrez l\'adresse du client',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                  ),
                ),
              ),
            ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addClientAddress,
                child: Text("Tracer le chemin "),
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),


        Container(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top:5.0)),
              SizedBox(
                width:200,
                height: 40,
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Numéro de téléphone",
                    border: OutlineInputBorder(),

                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top:10.0)),
          SizedBox(
            width:200,
            height: 40,
            child:
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
          )
            ],
          ),
        ),


        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Adresse du livreur: $_address',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: _submitAddress,
          child: Text("Envoyer"),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Obtenir la position du livreur',
        child: Icon(Icons.my_location),
      ),
    );
  }
}
