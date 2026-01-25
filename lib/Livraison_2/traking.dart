import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;

  const TrackingPage({super.key, required this.orderId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  double eta = 0;

  double calcETA(double dist) {
    return (dist / 1000) / 30 * 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("deliveries")
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final data = snapshot.data!;
          final driver = data["driverLocation"];
          final client = data["clientLocation"];

          if (driver == null || client == null) {
            return const Text("Attente GPS...");
          }

          double dist = Geolocator.distanceBetween(
            driver["lat"],
            driver["lng"],
            client["lat"],
            client["lng"],
          );

          eta = calcETA(dist);

          return Column(
            children: [
              Text("Distance: ${dist.toStringAsFixed(0)} m"),
              Text("ETA: ${eta.toStringAsFixed(0)} min"),

              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(driver["lat"], driver["lng"]),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("driver"),
                      position: LatLng(driver["lat"], driver["lng"]),
                    )
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}