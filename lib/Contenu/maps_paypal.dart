import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPages extends StatefulWidget {
  const MapPages({super.key});

  @override
  State<MapPages> createState() => _MapPagesState();
}

class _MapPagesState extends State<MapPages> {
  late MapController mapController;

  LatLng currentPosition = LatLng(48.8584, 2.2945);
  String address = "Récupération de l’adresse...";
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _requestLocationPermission();
  }


  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission localisation refusée"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });

      mapController.move(currentPosition, 16);
      _getAddress(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Erreur localisation : $e");
    }
  }


  Future<void> _getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;

      setState(() {
        address =
        "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      setState(() => address = "Adresse introuvable");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir l’adresse"),
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

          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentPosition,
                zoom: 15,
                onTap: (tapPosition, point) {
                  setState(() => currentPosition = point);
                  _getAddress(point.latitude, point.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=2xnZ3d7WBWgJCdFtjp7g',
                  userAgentPackageName: 'com.example.app',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xffB81736),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "📍 $address",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),


                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffB81736), Color(0xff281537)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (address.contains("introuvable")) return;
                      Navigator.pop(context, address);
                    },
                    child: const Text(
                      "Utiliser cette adresse",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffB81736),
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
