import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'fcm_utils.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

BuildContext? buildContext;
Map<String, dynamic> notificationMessage = <String, dynamic>{};

void registerLocalNotifications(BuildContext context) {
  buildContext = context;
  const android = AndroidInitializationSettings('@mipmap/ic_launcher_user');
  const iOS = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: iOS);
  flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );
}

void onDidReceiveNotificationResponse(NotificationResponse response) {
  if (buildContext != null) {
    navigateToScreen(
        context: buildContext!,
        message: notificationMessage,
        fromNotification: false);
  }
}

Future<void> showNotification(Map<String, dynamic> message) async {
  notificationMessage = message;
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  const platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
      0,
      Platform.isIOS
          ? (message["aps"]?["alert"]?["title"]?.toString() ?? '')
          : (message["notification"]?["title"]?.toString() ?? ''),
      Platform.isIOS
          ? (message["aps"]?["alert"]?["body"]?.toString() ?? '')
          : (message["notification"]?["body"]?.toString() ?? ''),
      platformChannelSpecifics,
      payload: 'item x');
}
