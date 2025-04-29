import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LocalNotification.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    String payloadData = jsonEncode(message.data);
    LocalNotification.simpleNotification(
      titile:message.notification!.title! ,
      body: message.notification!.body!,
      payload: payloadData,
    );
  }

}

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final SharedPreferences localDb = await SharedPreferences.getInstance();

    // Request permission for iOS devices


    // Generate the token and save it locally
    final token = await FirebaseMessaging.instance.getToken();
    print("Firebase Token: $token");
    await localDb.setString("firebaseToken", token!);
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('APNs Token: $apnsToken');


    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle the initial message when the app is opened
    messaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Setup the notification channel for Android
    await setupFlutterNotifications();

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
    });
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    if (message.notification != null) {
      String payloadData = jsonEncode(message.data);
      LocalNotification.simpleNotification(
        titile:message.notification!.title! ,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  }

  Future<void> setupFlutterNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Create the Android notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize the plugin for displaying notifications on the device
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Set foreground notification presentation options for iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Make sure this matches your channel ID
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            icon: 'launch_background', // Change this to your app's icon
          ),
        ),
      );
    }
  }
}
