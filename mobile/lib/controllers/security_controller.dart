import 'package:flutter/material.dart';
import '../models/spam_message.dart';
import '../services/api_service.dart';

class SecurityController extends ChangeNotifier {
  List<SpamMessage> _messages = [];
  SecurityStats? _stats;
  bool _isLoading = false;

  List<SpamMessage> get messages => _messages;
  SecurityStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load messages
      final messagesData = await ApiService.getSpamMessages();
      _messages = messagesData.map((json) => SpamMessage.fromJson(json)).toList();

      // Load stats
      final statsData = await ApiService.getSpamStats();
      _stats = SecurityStats.fromJson(statsData);
    } catch (e) {
      print('Error loading security data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    try {
      await ApiService.markSpamAsRead(id);
      await loadData();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      await ApiService.deleteSpamMessage(id);
      await loadData();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }
}
