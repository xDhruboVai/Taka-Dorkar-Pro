import 'package:flutter/material.dart';
import 'package:mobile/models/account_model.dart';
import 'package:mobile/services/local_database.dart';
import 'package:uuid/uuid.dart';

class AccountController with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  double get totalBalance =>
      _accounts.fold(0, (sum, item) => sum + item.balance);

  Map<String, List<Account>> get groupedAccounts {
    final Map<String, List<Account>> grouped = {};
    for (var account in _accounts) {
      if (!grouped.containsKey(account.parentType)) {
        grouped[account.parentType] = [];
      }
      grouped[account.parentType]!.add(account);
    }
    return grouped;
  }

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final db = LocalDatabase.instance;
      final data = await db.query('accounts');
      _accounts = data.map((item) => Account.fromLocalDb(item)).toList();
    } catch (e) {
      _hasError = true;
      debugPrint('Error fetching accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAccount(
    String name,
    String type,
    String parentType,
    double balance,
  ) async {
    try {
      final db = LocalDatabase.instance;
      final uuid = const Uuid();
      final accountId = uuid.v4();
      final now = DateTime.now().toIso8601String();

      final accountData = {
        'id': accountId,
        'user_id': 'current_user',
        'name': name,
        'type': type,
        'balance': balance,
        'currency': 'BDT',
        'parent_type': parentType,
        'is_default': 0,
        'include_in_savings': 0,
        'created_at': now,
        'updated_at': now,
        'local_updated_at': now,
        'needs_sync': 1,
      };

      await db.insert('accounts', accountData);
      print('AccountController: Created account in local DB');

      await fetchAccounts();
    } catch (e) {
      print('AccountController: Error creating account: $e');
      rethrow;
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final db = LocalDatabase.instance;
      final now = DateTime.now().toIso8601String();

      await db.update(
        'accounts',
        {
          'balance': newBalance,
          'updated_at': now,
          'local_updated_at': now,
          'needs_sync': 1,
        },
        where: 'id = ?',
        whereArgs: [accountId],
      );
      print('AccountController: Updated account balance in local DB');

      await fetchAccounts();
    } catch (e) {
      print('AccountController: Error updating account: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(String accountId) async {
    try {
      final db = LocalDatabase.instance;
      await db.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
      print('AccountController: Deleted account from local DB');

      await fetchAccounts();
    } catch (e) {
      print('AccountController: Error deleting account: $e');
      rethrow;
    }
  }

  Future<void> createDefaultAccounts(String userId) async {
    try {
      final db = LocalDatabase.instance;
      final uuid = const Uuid();
      final now = DateTime.now().toIso8601String();

      final defaultAccounts = [
        {'name': 'Wallet', 'parent_type': 'cash', 'balance': 0.0},
        {'name': 'BKash', 'parent_type': 'mobile_banking', 'balance': 0.0},
        {'name': 'Nagad', 'parent_type': 'mobile_banking', 'balance': 0.0},
        {'name': 'EBL', 'parent_type': 'bank', 'balance': 0.0},
        {
          'name': 'Personal Savings',
          'parent_type': 'savings',
          'balance': 1000.0,
        },
      ];

      for (var acc in defaultAccounts) {
        final accountData = {
          'id': uuid.v4(),
          'user_id': userId,
          'name': acc['name'] as String,
          'type': acc['parent_type'] as String,
          'balance': acc['balance'] as double,
          'currency': 'BDT',
          'parent_type': acc['parent_type'] as String,
          'is_default': 1,
          'include_in_savings': acc['name'] == 'Personal Savings' ? 1 : 0,
          'created_at': now,
          'updated_at': now,
          'local_updated_at': now,
          'needs_sync': 1,
        };

        await db.insert('accounts', accountData);
      }

      print('AccountController: Created default accounts in local DB');
      await fetchAccounts();
    } catch (e) {
      print('AccountController: Error creating default accounts: $e');
      rethrow;
    }
  }
}
