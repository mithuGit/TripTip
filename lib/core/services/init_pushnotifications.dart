import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

// This class is used to handel the push notifications in Firebase
// Must be here: https://stackoverflow.com/questions/67304706/flutter-fcm-unhandled-exception-null-check-operator-used-on-a-null-value
Future handelBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  // Every Andoird local Nottifcation must have a channel

  final android = const AndroidNotificationDetails(
    'my_app_channel',
    'my_app_channel',
    channelDescription: 'A Notification Channel for the TripTip App',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

   final AndroidNotificationChannel channel =  const AndroidNotificationChannel(
        'my_app_channel', 'my_app_channel',
        description: 'This channel is used for important notifications.',
        importance: Importance.defaultImportance,
        showBadge: true,
        enableVibration: true,
        playSound: true);
  // This Function is called when a User clicks on a Notification

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    debugPrint('Handling a foreground message ${message.messageId}');
    if (message.data["goToDay"] != null) {
      if (message.data["day"] == null) return;
      if (message.data["trip"] == null) return;
      BuildContext? context =
          MyRouter.router.routerDelegate.navigatorKey.currentContext;
      //MyRouter.rootNavigatorDashboard.currentState?.popUntil((route) => route.isFirst);
      if (context == null) return;
      context.push('/',
          extra: {"day": message.data["day"], "trip": message.data["trip"]});
    }
  }

  // This Function is called when the App is started
  Future initalize() async {
    if (await _fcm.isSupported()) {
      debugPrint('FCM is supported and will be initalized');
    } else {
      debugPrint('FCM is not supported');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final bool userWantsPushNotifications =
        prefs.getBool('userwantspushnotifications') ?? false;
    if (userWantsPushNotifications) {
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
            debugPrint('FirebaseMessaging token: $fcmToken');    
          }
        }
      }).onError((err) {
        // Error getting token.
      });
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
      FirebaseMessaging.onBackgroundMessage(handelBackgroundMessage);
      await enableLocalNotification();

      onNotifications.stream.listen((String? payload) {
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      });
    }
  }
  // This Function is called when the User wants to enable Push Notifications

  Future<void> gantPushNotifications() async {
    if (await _fcm.isSupported()) {
      debugPrint('FCM is supported');
    } else {
      debugPrint('FCM is not supported');
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
        return;
      }
      return;
    }
    _fcm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    final token = await _fcm.getToken();
    debugPrint('FirebaseMessaging token: $token');
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

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('userwantspushnotifications', true);
    await initalize();
  }
  // This Function is called on the Settings Page to check if the User has enabled Push Notifications

  Future<bool> checkIfNotificationIsEnabled() async {
    print("checkIfNotificationIsEnabled");
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final bool userWantsPushNotifications =
        prefs.getBool('userwantspushnotifications') ?? false;
    if (!userWantsPushNotifications) {
      if (auth.currentUser != null) {
        DocumentSnapshot doc = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get();
        if (doc.exists) {
          return (doc.data()! as Map<String, dynamic>)['fcm_token'] != null;
        }
        
      }
      return false;
    } else {
      return true;
    }
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
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('userwantspushnotifications', false);
  }

  Future enableLocalNotification() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await notificationsPlugin.initialize(initializationSettings,
        // this is the callback that is called when the user taps on a notification
        onDidReceiveNotificationResponse: (payload) async {
      onNotifications.add(payload.payload);
    });
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
              notification.body, platform,
              payload: jsonEncode(message.toMap()));
        }
      }
    });
  }
}
