import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static void startTracking(String orderId) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      FirebaseFirestore.instance
          .collection("deliveries")
          .doc(orderId)
          .update({
        "driverLocation": {
          "lat": pos.latitude,
          "lng": pos.longitude,
        },
        "status": "on_the_way",
      });
    });
  }
}