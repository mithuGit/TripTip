import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// Must be here: https://stackoverflow.com/questions/67304706/flutter-fcm-unhandled-exception-null-check-operator-used-on-a-null-value
Future handelBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final android = const AndroidNotificationDetails(
    'my_app_channel',
    'my_app_channel',
    channelDescription: 'channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  Future checkInitialized() async {
    if (!_fcm.isAutoInitEnabled) {
      await _fcm.setAutoInitEnabled(true);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      if (auth.currentUser != null) {
        DocumentSnapshot doc = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get();
        if (doc.exists) {
          await firestore
              .collection('users')
              .doc(auth.currentUser!.uid)
              .update({'fcm_token': fcmToken});
        }
      }
    }).onError((err) {
      // Error getting token.
    });
    await enableLocalNotification();
  }

  Future initialise() async {
    if (await _fcm.isSupported()) {
      print('FCM is supported');
    } else {
      print('FCM is not supported');
      return;
    }
    NotificationSettings settings = await _fcm.requestPermission(
        provisional: false,
        sound: true,
        badge: true,
        alert: false,
        announcement: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      var status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }
    _fcm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

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
    if (token != null) {
      FirebaseMessaging.onBackgroundMessage(handelBackgroundMessage);
      await enableLocalNotification();
    }
  }

  Future<bool> checkIfNotificationIsEnabled() async {
    print("checkIfNotificationIsEnabled");
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      return false;
    }
    if (auth.currentUser != null) {
      DocumentSnapshot doc =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      if (doc.exists) {
        return (doc.data()! as Map<String, dynamic>)['fcm_token'] != null;
      }
    }
    return false;
  }

  Future<void> disable() async {
    if (auth.currentUser != null) {
      DocumentSnapshot doc =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      if (doc.exists) {
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update({'fcm_token': null});
      }
    }
    await _fcm.deleteToken();
    await _fcm.setAutoInitEnabled(false);
    await notificationsPlugin.cancelAll();
  }

  Future enableLocalNotification() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'my_app_channel', 'my_app_channel',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        playSound: true);
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await notificationsPlugin.initialize(initializationSettings);
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isAndroid) {
        RemoteNotification? notification = message.notification;
        var platform = NotificationDetails(android: android);
        if (notification != null) {
          notificationsPlugin.show(notification.hashCode, notification.title, 
              notification.body, platform);
        }
      }
    });
  }
}
