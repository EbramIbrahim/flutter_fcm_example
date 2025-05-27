import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingConfig {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  configRemoteNotification() async {
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(provisional: true);
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      configLocalNotification();

      FirebaseMessaging.instance.getToken().then(
        (value) => print("token: $value"),
      );

      FirebaseMessaging.onMessage.listen((message) {
        log(message.notification!.body.toString());
        log(message.notification!.title.toString());
        showLocalNotification(message.notification!.body, message.notification!.title);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        log(message.notification!.body.toString());
        log(message.notification!.title.toString());
      });
    }
  }

  configLocalNotification() async {
    const AndroidInitializationSettings initializationAndroidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final DarwinInitializationSettings initializationDarwinSettings =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationAndroidSettings,
          iOS: initializationDarwinSettings,
        );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (onSelectNotification) {
        final String? payload = onSelectNotification.payload;
        if (onSelectNotification.payload != null) {
          log('notification payload $payload');
        }
      },
    );
  }

  showLocalNotification(title, description) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "channelId",
          "channelName",
          channelDescription: "channel description",
          importance: Importance.max,
          priority: Priority.high,
          ticker: "ticker",
        );

    const NotificationDetails platformNotificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      description,
      platformNotificationDetails,
      payload: "Here is the payload",
    );
  }
}
