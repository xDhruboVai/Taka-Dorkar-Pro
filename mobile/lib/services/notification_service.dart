import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> showSpamDetected({
    required String phoneNumber,
    required String messagePreview,
    required String threatLevel,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'spam_detection',
      'Spam Detection',
      channelDescription: 'Notifications for detected spam messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color.fromARGB(255, 255, 0, 0),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = threatLevel == 'high'
        ? '🚨 High Threat Detected'
        : threatLevel == 'medium'
        ? '⚠️ Suspicious Message'
        : 'ℹ️ Spam Detected';

    final body =
        'From: $phoneNumber\n${messagePreview.substring(0, messagePreview.length > 50 ? 50 : messagePreview.length)}...';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: phoneNumber,
    );
  }

  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}
