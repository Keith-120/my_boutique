import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryService {
  static Future<String?> assignNearestDriver(
      double lat,
      double lng,
      ) async {
    final drivers = await FirebaseFirestore.instance
        .collection("drivers")
        .where("isAvailable", isEqualTo: true)
        .get();

    double minDist = 999999;
    String? best;

    for (var d in drivers.docs) {
      final loc = d["lastLocation"];
      if (loc == null) continue;

      double dist = Geolocator.distanceBetween(
        lat,
        lng,
        loc["lat"],
        loc["lng"],
      );

      if (dist < minDist) {
        minDist = dist;
        best = d.id;
      }
    }

    return best;
  }
}