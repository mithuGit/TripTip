import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future handelBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }

  Future initialise() async {
    await _fcm.requestPermission(
        provisional: true,
        sound: true,
        badge: true,
        alert: true,
        announcement: true);
    final token = await _fcm.getToken();
    print('FirebaseMessaging token: $token');
    if (token != null && auth.currentUser != null) {
      DocumentSnapshot doc =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      if (doc.exists) {
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update({'fcm_token': token});
      }
    }

    FirebaseMessaging.onBackgroundMessage(handelBackgroundMessage);
  }
}
