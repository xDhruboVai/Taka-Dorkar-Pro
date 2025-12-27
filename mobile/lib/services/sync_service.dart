import 'package:mobile/services/local_database.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:developer' show log;

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  bool _isSyncing = false;

  Future<void> syncAll() async {
    if (_isSyncing) {
      log('SyncService: Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    log('SyncService: Starting sync...');

    try {
      await _syncAccounts();
      log('SyncService: Sync completed successfully');
    } catch (e) {
      log('SyncService: Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncAccounts() async {
    try {
      final db = LocalDatabase.instance;
      final unsyncedAccounts = await db.getUnsyncedRecords('accounts');

      if (unsyncedAccounts.isEmpty) {
        log('SyncService: No accounts to sync');
        return;
      }

      log('SyncService: Syncing ${unsyncedAccounts.length} accounts...');

      for (var account in unsyncedAccounts) {
        try {
          await ApiService.post('/sync/accounts', account);
          await db.markAsSynced('accounts', account['id'] as String);
          log('SyncService: Synced account ${account['id']}');
        } catch (e) {
          log('SyncService: Failed to sync account ${account['id']}: $e');
        }
      }

      await db.updateSyncLog('accounts', DateTime.now().toIso8601String());
    } catch (e) {
      log('SyncService: Error in _syncAccounts: $e');
    }
  }
}
