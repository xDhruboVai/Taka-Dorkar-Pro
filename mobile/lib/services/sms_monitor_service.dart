import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import './fraud_detection_service.dart';
import './notification_service.dart';
import './api_service.dart';

class SmsMonitorService {
  static final Telephony telephony = Telephony.instance;
  static bool _isMonitoring = false;

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
        throw Exception('SMS permissions not granted');
      }
    }

    // Initialize fraud detection
    await FraudDetectionService.initialize();
    await NotificationService.initialize();

    // Listen for incoming SMS
    telephony.listenIncomingSms(
      onNewMessage: _onMessageReceived,
      onBackgroundMessage: _backgroundMessageHandler,
      listenInBackground: true,
    );

    _isMonitoring = true;
    print('✅ SMS monitoring started');
  }

  // Stop monitoring
  static void stopMonitoring() {
    _isMonitoring = false;
    print('⏹️ SMS monitoring stopped');
  }

  // Handle incoming SMS
  static Future<void> _onMessageReceived(SmsMessage message) async {
    print('📱 New SMS received from: ${message.address}');
    await _processSms(message);
  }

  // Background message handler
  static Future<void> _backgroundMessageHandler(SmsMessage message) async {
    print('📱 Background SMS: ${message.address}');
    await FraudDetectionService.initialize();
    await NotificationService.initialize();
    await _processSms(message);
  }

  // Process and detect spam
  static Future<void> _processSms(SmsMessage message) async {
    try {
      final messageText = message.body ?? '';
      final phoneNumber = message.address ?? 'Unknown';

      // Skip if empty
      if (messageText.isEmpty) return;

      // Run ML detection
      final result = await FraudDetectionService.detectSpam(messageText);
      
      final isSpam = result['isSpam'] as bool;
      final prediction = result['prediction'] as String;
      final confidence = result['confidence'] as double;
      final threatLevel = result['threatLevel'] as String;

      // If spam detected
      if (isSpam || prediction == 'promo') {
        // Show notification
        await NotificationService.showSpamDetected(
          phoneNumber: phoneNumber,
          messagePreview: messageText,
          threatLevel: threatLevel,
        );

        // Send to backend API
        try {
          await ApiService.detectSpam(
            phoneNumber: phoneNumber,
            messageText: messageText,
            mlPrediction: prediction,
            mlConfidence: confidence,
          );
        } catch (e) {
          print('❌ Failed to send to backend: $e');
          // Continue even if backend fails
        }

        print('🚨 Spam detected: $prediction ($threatLevel) - ${(confidence * 100).toStringAsFixed(1)}%');
      }
    } catch (e) {
      print('❌ Error processing SMS: $e');
    }
  }

  // Get SMS inbox (for initial scan)
  static Future<List<SmsMessage>> getInbox() async {
    final hasPerms = await hasPermissions();
    if (!hasPerms) return [];

    final messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    return messages;
  }

  // Scan existing messages
  static Future<int> scanExistingMessages({int limit = 50}) async {
    final messages = await getInbox();
    int spamCount = 0;

    for (int i = 0; i < messages.length && i < limit; i++) {
      final message = messages[i];
      final result = await FraudDetectionService.detectSpam(message.body ?? '');
      
      if (result['isSpam'] as bool) {
        spamCount++;
      }
    }

    return spamCount;
  }
}
