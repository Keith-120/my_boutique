import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  static Future<void> init(String driverId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();

    await FirebaseFirestore.instance
        .collection("drivers")
        .doc(driverId)
        .set({"fcmToken": token}, SetOptions(merge: true));
  }
}