import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import './fraud_detection_service.dart';
import './notification_service.dart';
import './api_service.dart';
import './security_repository.dart';
import '../models/spam_message.dart';

class SmsMonitorService {
  static const MethodChannel _channel = MethodChannel('com.example.mobile/sms');
  static bool _isMonitoring = false;
  static final SecurityRepository _repository = SecurityRepository();

  static bool get isMonitoring => _isMonitoring;

  // Request SMS permissions
  static Future<bool> requestPermissions() async {
    final smsPermission = await Permission.sms.request();
    final notificationPermission = await Permission.notification.request();

    return smsPermission.isGranted && notificationPermission.isGranted;
  }

  // Check if permissions are granted
  static Future<bool> hasPermissions() async {
    final smsStatus = await Permission.sms.status;
    return smsStatus.isGranted;
  }

  // Start monitoring SMS
  static Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    final hasPerms = await hasPermissions();
    if (!hasPerms) {
      final granted = await requestPermissions();
      if (!granted) {
        print('⚠️ SMS permissions not granted for monitoring');
        return;
      }
    }

    // Initialize fraud detection
    try {
      await FraudDetectionService.initialize();
    } catch (e) {
      print(
        '❌ Error initializing FraudDetectionService: $e. Continuing without ML detection.',
      );
      // Continue execution even if initialization fails
    }
    await NotificationService.initialize();

    // Catch-up: Scan last 20 messages for missed spam
    await scanInbox(limit: 20);

    // Listen for incoming SMS via MethodChannel
    _channel.setMethodCallHandler(_handleMethodCall);

    _isMonitoring = true;
    print('✅ SMS monitoring started (via MethodChannel)');
  }

  // Scan recent inbox messages for missed spam
  static Future<void> scanInbox({int limit = 50}) async {
    try {
      print('🔍 Scanning last $limit inbox messages...');
      final List<dynamic> messages = await _channel.invokeMethod(
        'getInboxMessages',
        {'limit': limit},
      );

      for (var msg in messages) {
        final String senderAddress = msg['sender'] ?? 'Unknown';
        final String text = msg['message'] ?? '';

        // Skip if empty
        if (text.isEmpty) continue;

        // Process silently
        await _processSms(senderAddress, text, silent: true);
      }
      print('✅ Inbox scan complete');
    } catch (e) {
      print('❌ Inbox scan failed: $e');
    }
  }

  // Stop monitoring
  static void stopMonitoring() {
    _channel.setMethodCallHandler(null);
    _isMonitoring = false;
    print('⏹️ SMS monitoring stopped');
  }

  // Handle incoming method calls from native side
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSmsReceived':
        final Map<dynamic, dynamic> args = call.arguments;
        final String sender = args['sender'] ?? 'Unknown';
        final String message = args['message'] ?? '';
        print('📱 New SMS received from: $sender');
        await _processSms(sender, message);
        break;
      case 'onPermissionResult':
        final bool granted = call.arguments as bool;
        print('🔑 SMS Permission status: ${granted ? "Granted" : "Denied"}');
        break;
      default:
        print('❓ Unknown method called from native: ${call.method}');
    }
  }

  // Process and detect spam
  static Future<void> _processSms(
    String phoneNumber,
    String messageText, {
    bool silent = false,
  }) async {
    try {
      if (messageText.isEmpty) return;

      // Ensure services are initialized
      await FraudDetectionService.initialize();

      // Run ML detection
      final result = await FraudDetectionService.detectSpam(messageText);
      final isSpam = result['isSpam'] as bool;
      final prediction = result['prediction'] as String;
      final confidence = result['confidence'] as double;
      final threatLevel = result['threatLevel'] as String;

      if (isSpam || prediction == 'promo') {
        final spamMsg = SpamMessage(
          userId: 'local', // Will be updated on sync
          phoneNumber: phoneNumber,
          messageText: messageText,
          detectionMethod: 'local',
          threatLevel: threatLevel,
          mlConfidence: confidence,
          detectedAt: DateTime.now(),
        );

        // ALWAYS save locally first (Security 2.0 Core)
        await _repository.saveSpamLocally(spamMsg);

        if (!silent) {
          await NotificationService.initialize();
          await NotificationService.showSpamDetected(
            phoneNumber: phoneNumber,
            messagePreview: messageText,
            threatLevel: threatLevel,
          );
        }

        // Background sync to backend
        try {
          await ApiService.detectSpam(
            phoneNumber: phoneNumber,
            messageText: messageText,
            mlPrediction: prediction,
            mlConfidence: confidence,
          );
        } catch (e) {
          print('⏳ Backend sync pending (saved locally): $phoneNumber');
        }
      }
    } catch (e) {
      print('❌ Error processing SMS: $e');
    }
  }

  // Test notification
  static Future<void> testNotification() async {
    await NotificationService.showSpamDetected(
      phoneNumber: 'SEC-TEST',
      messagePreview: 'This is a simulated smishing attack for validation.',
      threatLevel: 'high',
    );
  }
}
