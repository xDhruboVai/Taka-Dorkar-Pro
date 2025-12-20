import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    _isInitialized = true;
    print('✅ NotificationService initialized');
  }

  static Future<void> showSpamDetected({
    required String phoneNumber,
    required String messagePreview,
    required String threatLevel,
  }) async {
    print('🔔 Attempting to show notification for: $phoneNumber');
    await initialize();

    final severityColor = threatLevel == 'high' 
        ? const Color(0xFFFF0000) 
        : const Color(0xFFFF9800);

    final androidDetails = AndroidNotificationDetails(
      'security_alerts_v2',
      'Security Alerts',
      channelDescription: 'Critical alerts for detected phishing and spam',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: severityColor,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        'Detected $threatLevel threat from $phoneNumber\n\n$messagePreview',
        contentTitle: threatLevel == 'high' ? '🚨 High Threat Detected' : '⚠️ Suspicious Message',
        summaryText: 'Security Alert',
      ),
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        threatLevel == 'high' ? '🚨 Security Alert' : '⚠️ Suspicious SMS',
        'From: $phoneNumber',
        details,
        payload: phoneNumber,
      );
      print('✅ Notification sent to system');
    } catch (e) {
      print('❌ Failed to show notification: $e');
    }
  }

  static Future<void> requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
}
