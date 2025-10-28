import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    final options = _firebaseOptionsFromEnv();
    if (options != null) {
      await Firebase.initializeApp(options: options);
    }
  }
}

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<RemoteMessage>? _subscription;
  bool _mocked = false;

  Future<void> initialize() async {
    final options = _firebaseOptionsFromEnv();
    if (options == null) {
      _mocked = true;
      return;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _messaging.requestPermission();

    if (!kIsWeb) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _subscription = FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    await _messaging.getToken();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  bool get isMocked => _mocked;

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }
    final androidDetails = AndroidNotificationDetails(
      'vendor_push',
      'Vendor Notifications',
      importance: Importance.max,
      priority: Priority.high,
      channelDescription: 'Alerts from customers, orders, and leads',
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Appydex Vendor',
      notification.body,
      details,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }
}

FirebaseOptions? _firebaseOptionsFromEnv() {
  final apiKey = dotenv.maybeGet(EnvKeys.firebaseApiKey);
  final appId = dotenv.maybeGet(EnvKeys.firebaseAppId);
  final messagingSenderId = dotenv.maybeGet(EnvKeys.firebaseMessagingSenderId);
  final projectId = dotenv.maybeGet(EnvKeys.firebaseProjectId);
  if ([apiKey, appId, messagingSenderId, projectId].any((value) => value == null || value!.isEmpty)) {
    return null;
  }
  return FirebaseOptions(
    apiKey: apiKey!,
    appId: appId!,
    messagingSenderId: messagingSenderId!,
    projectId: projectId!,
    storageBucket: '$projectId.appspot.com',
  );
}
