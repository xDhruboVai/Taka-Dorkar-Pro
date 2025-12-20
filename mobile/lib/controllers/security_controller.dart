import 'package:flutter/material.dart';
import '../models/spam_message.dart';
import '../services/sms_monitor_service.dart';
import '../services/security_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class SecurityController extends ChangeNotifier {
  final SecurityRepository _repository = SecurityRepository();

  List<SpamMessage> _messages = [];
  SecurityStats? _stats;
  bool _isLoading = false;
  String? _error;

  SecurityController() {
    _repository.onMessageAdded.listen((_) {
      loadData();
    });
  }

  List<SpamMessage> get messages => _messages;
  SecurityStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Diagnostic Getters
  bool get isMonitoring => SmsMonitorService.isMonitoring;
  // Hybrid service is always initialized
  bool get isModelLoaded => true;

  Future<bool> get hasSmsPermission async => await Permission.sms.isGranted;
  Future<bool> get hasNotificationPermission async =>
      await Permission.notification.isGranted;

  Future<void> toggleMonitoring() async {
    if (isMonitoring) {
      SmsMonitorService.stopMonitoring();
      notifyListeners();
      return;
    }

    // Check permissions first
    final hasSms = await Permission.sms.isGranted;
    final hasNotif = await Permission.notification.isGranted;

    if (!hasSms || !hasNotif) {
      // Request permissions
      final smsResult = await Permission.sms.request();
      final notifResult = await Permission.notification.request();

      if (!smsResult.isGranted || !notifResult.isGranted) {
        _error = 'Permissions required: SMS and Notifications';
        notifyListeners();
        return;
      }
    }

    // Try to start monitoring
    try {
      await SmsMonitorService.startMonitoring();
      _error = null;
    } catch (e) {
      _error = 'Failed to start monitoring: ${e.toString()}';
      debugPrint('Toggle error: $e');
    }
    notifyListeners();
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Load from Local First (Immediate UI update)
      _messages = await _repository.getSpamMessages();
      _stats = await _repository.getStats();
      notifyListeners();

      // 2. If force refresh, or background sync
      if (forceRefresh) {
        await _repository.syncSpam();
        // Reload after sync
        _messages = await _repository.getSpamMessages();
        _stats = await _repository.getStats();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('SecurityController Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      // Optimistic update locally
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        // We need a way to create a copy with isRead = true
        // For now, reload data is safer but potentially slower
        await loadData();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      await _repository.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
      // Also update stats
      _stats = await _repository.getStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }
}
