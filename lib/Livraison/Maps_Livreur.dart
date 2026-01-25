import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class MapsLivreur extends StatefulWidget {
  final String adresseClient;
  final String nomClient;
  final String telephoneClient;

  const MapsLivreur({
    super.key,
    required this.adresseClient,
    required this.nomClient,
    required this.telephoneClient,
  });

  @override
  State<MapsLivreur> createState() => MapsLivreurState();
}

class MapsLivreurState extends State<MapsLivreur> {
  late MapController mapController;

  LatLng livreurPosition = LatLng(48.8584, 2.2945);
  LatLng clientPosition = LatLng(48.8619, 2.3314);
  List<LatLng> routePoints = [];

  String livreurAddress = "Localisation du livreur";

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initProcess();
  }

  Future<void> _initProcess() async {
    await _demanderPermission();
    await _localiserClient(widget.adresseClient);
  }

  Future<void> _demanderPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getLivreurLocation();
    } else {
      Fluttertoast.showToast(msg: "Permission localisation refusée");
    }
  }

  Future<void> _getLivreurLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      livreurPosition = LatLng(position.latitude, position.longitude);
      mapController.move(livreurPosition, 14);

      await _getLivreurAddress(position.latitude, position.longitude);
      _getRoute(livreurPosition, clientPosition);

      setState(() {});
    } catch (e) {
      debugPrint("Erreur GPS livreur : $e");
    }
  }

  Future<void> _getLivreurAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      livreurAddress =
      "${place.street}, ${place.locality}, ${place.country}";
    } catch (_) {
      livreurAddress = "Adresse inconnue";
    }
  }

  Future<void> _localiserClient(String adresse) async {
    try {
      final locations = await locationFromAddress(adresse);
      clientPosition =
          LatLng(locations.first.latitude, locations.first.longitude);

      _getRoute(livreurPosition, clientPosition);
      mapController.move(clientPosition, 14);
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: "Adresse client introuvable");
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url =
        "http://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];

      routePoints =
          coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🗺️ Itinéraire livraison"),
        backgroundColor: const Color(0xffB81736),
      ),

      body: Column(
        children: [
          // 🔹 INFOS CLIENT
          Card(
            margin: const EdgeInsets.all(12),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 ${widget.nomClient}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("📞 ${widget.telephoneClient}"),
                  const SizedBox(height: 6),
                  Text("📍 ${widget.adresseClient}"),
                ],
              ),
            ),
          ),

          // 🔹 MAP
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: livreurPosition,
                zoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=2xnZ3d7WBWgJCdFtjp7g',
                  userAgentPackageName: 'com.example.app',
                ),

                MarkerLayer(markers: [
                  Marker(
                    point: livreurPosition,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.delivery_dining,
                        color: Colors.red, size: 40),
                  ),
                  Marker(
                    point: clientPosition,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 40),
                  ),
                ]),

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
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffB81736),
        onPressed: _getLivreurLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
