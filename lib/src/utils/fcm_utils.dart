import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../apis/dic_params.dart';
import '../ui/chat/provider/chat_provider.dart';
import '../ui/profile/supportTickets/provider/support_chat_provider.dart';
import 'constants.dart';
import 'local_notifications.dart';
import 'navigation.dart';
import 'navigation_params.dart';
import 'notification_constants.dart';
import 'preference_key.dart';
import 'preference_utils.dart';

bool _isMessagingListenersRegistered = false;

Future<void> configureFirebaseMessaging() async {
  final firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.setAutoInitEnabled(true);
  await firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<String> getFcmTokenSafely({
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    final token = await FirebaseMessaging.instance.getToken().timeout(timeout);
    return token ?? "";
  } on TimeoutException {
    debugPrint("FCM: token request timed out, continuing without token");
    return "";
  } catch (e) {
    debugPrint("FCM: token request failed, continuing without token. error=$e");
    return "";
  }
}

Future<void> registerNotification(BuildContext context) async {
  final firebaseMessaging = FirebaseMessaging.instance;
  try {
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint("FCM: requestPermission failed. error=$e");
  }

  registerLocalNotifications(context);

  if (!_isMessagingListenersRegistered) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FlutterAppBadger.updateBadgeCount(1);
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateToScreen(
        context: context,
        message: _remoteMessageToMap(message),
        fromNotification: true,
      );
    });

    _isMessagingListenersRegistered = true;
  }

  try {
    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      navigateToScreen(
        context: context,
        message: _remoteMessageToMap(initialMessage),
        fromNotification: true,
      );
    }
  } catch (e) {
    debugPrint("FCM: getInitialMessage failed. error=$e");
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may already be initialized in this isolate.
  }
}

void navigateToScreen({
  required BuildContext context,
  required Map<String, dynamic> message,
  required bool fromNotification,
}) {
  switch (Platform.isAndroid
      ? message[DicParams.data][DicParams.actionType]
      : message[DicParams.actionType]) {
    case NotificationConstants.requested:
      openChatScreen(context, message);
      break;
    case NotificationConstants.userChat:
      openChatScreen(context, message);
      break;
    case NotificationConstants.approved:
      openChatScreen(context, message);
      break;
    case NotificationConstants.support:
      getString(PreferenceKey.routeName) == routeSupportTickets
          ? NavigationUtils.pushReplacement(
              context,
              routeSupportTickets,
              arguments: {NavigationParams.showBackButton: true},
            )
          : NavigationUtils.push(
              context,
              routeSupportTickets,
              arguments: {NavigationParams.showBackButton: true},
            );
      break;
    case NotificationConstants.chat:
      openChatScreen(context, message);
      break;
    case NotificationConstants.supportChat:
      openSupportChatScreen(context, message);
      break;
    case NotificationConstants.newMessage:
      openSupportChatScreen(context, message);
      break;
    case NotificationConstants.ticketClosed:
      openSupportChatScreen(context, message);
      break;

    default:
      break;
  }
}

void openSupportChatScreen(BuildContext context, Map<String, dynamic> message) {
  final ticketId = int.parse(
    Platform.isAndroid
        ? message[DicParams.data][DicParams.ticketId]
        : message[DicParams.ticketId],
  );
  if (Provider.of<SupportChatProvider>(context, listen: false).ticketId !=
      ticketId) {
    if (Provider.of<SupportChatProvider>(context, listen: false).isScreenOpen) {
      NavigationUtils.pushReplacement(
        context,
        routeSupportTicketsChat,
        arguments: {NavigationParams.senderUserId: ticketId},
      );
    } else {
      NavigationUtils.push(
        context,
        routeSupportTicketsChat,
        arguments: {NavigationParams.senderUserId: ticketId},
      );
    }
  }
}

void openChatScreen(BuildContext context, Map<String, dynamic> message) {
  final userId = int.parse(
    Platform.isAndroid
        ? message[DicParams.data][DicParams.userId]
        : message[DicParams.userId],
  );
  if (Provider.of<ChatProvider>(context, listen: false).userId != userId) {
    if (Provider.of<ChatProvider>(context, listen: false).isScreenOpen) {
      NavigationUtils.pushReplacement(
        context,
        routeChatScreen,
        arguments: {NavigationParams.senderUserId: userId},
      );
    } else {
      NavigationUtils.push(
        context,
        routeChatScreen,
        arguments: {NavigationParams.senderUserId: userId},
      );
    }
  }
}

Map<String, dynamic> _remoteMessageToMap(RemoteMessage message) {
  final map = <String, dynamic>{};
  map[DicParams.data] = message.data;
  map[DicParams.actionType] = message.data[DicParams.actionType];
  if (message.notification != null) {
    map["notification"] = {
      "title": message.notification?.title,
      "body": message.notification?.body,
    };
    map["aps"] = {
      "alert": {
        "title": message.notification?.title,
        "body": message.notification?.body,
      },
    };
  }
  return map;
}

Future<void> showNotification(RemoteMessage message) async {
  notificationMessage = _remoteMessageToMap(message);
  final title =
      message.notification?.title ?? message.data["title"]?.toString();
  final body = message.notification?.body ?? message.data["body"]?.toString();

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
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}
