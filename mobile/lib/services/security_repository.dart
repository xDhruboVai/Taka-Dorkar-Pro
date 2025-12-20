import '../models/spam_message.dart';
import './local_database.dart';
import './api_service.dart';
import 'package:flutter/foundation.dart';

class SecurityRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  Future<void> saveSpamLocally(SpamMessage message) async {
    await _db.insertSpamMessage(message.toJson());
  }

  Future<List<SpamMessage>> getSpamMessages() async {
    final maps = await _db.getSpamMessages();
    return maps.map((m) => SpamMessage.fromJson(m)).toList();
  }

  Future<SecurityStats> getStats() async {
    try {
      // Try to get from backend first
      final backendStats = await ApiService.getSpamStats();
      return SecurityStats.fromJson(backendStats);
    } catch (e) {
      debugPrint('Failed to fetch backend stats, using local: $e');
      // Fallback to local stats
      final localStats = await _db.getLocalSecurityStats();
      return SecurityStats.fromJson(localStats);
    }
  }

  Future<void> syncSpam() async {
    // In Security 2.0, we can implement a more complex sync logic here if needed
    // For now, let's focus on the local-first flow
  }

  Future<void> markAsRead(int id) async {
    await _db.markSpamAsRead(id);
    // Optionally fire-and-forget sync to backend
    try {
      // Assuming ApiService has a markAsRead method or similar
    } catch (_) {}
  }

  Future<void> deleteMessage(int id) async {
    await _db.deleteSpamMessage(id);
  }
}
