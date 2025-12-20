import '../models/spam_message.dart';
import './local_database.dart';
import './api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class SecurityRepository {
  static final SecurityRepository _instance = SecurityRepository._internal();
  factory SecurityRepository() => _instance;
  SecurityRepository._internal();

  final LocalDatabase _db = LocalDatabase.instance;
  final _messageStreamController = StreamController<void>.broadcast();

  Stream<void> get onMessageAdded => _messageStreamController.stream;

  Future<void> saveSpamLocally(SpamMessage message) async {
    await _db.insertSpamMessage(message.toJson());
    _messageStreamController.add(null);
  }

  Future<List<SpamMessage>> getSpamMessages() async {
    final maps = await _db.getSpamMessages();
    return maps.map((m) => SpamMessage.fromJson(m)).toList();
  }

  Future<SecurityStats> getStats() async {
    try {
      final backendStats = await ApiService.getSpamStats();
      return SecurityStats.fromJson(backendStats);
    } catch (e) {
      debugPrint('Failed to fetch backend stats, using local: $e');
      final localStats = await _db.getLocalSecurityStats();
      return SecurityStats.fromJson(localStats);
    }
  }

  Future<void> syncSpam() async {}

  Future<void> markAsRead(int id) async {
    await _db.markSpamAsRead(id);
    // Optionally fire-and-forget sync to backend
    try {} catch (_) {}
  }

  Future<void> deleteMessage(int id) async {
    await _db.deleteSpamMessage(id);
  }
}
