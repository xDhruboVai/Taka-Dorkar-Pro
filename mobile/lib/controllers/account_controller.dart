import 'package:flutter/material.dart';
import 'package:mobile/models/account_model.dart';
import 'package:mobile/services/api_service.dart';

class AccountController with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

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
    notifyListeners();
    try {
      final data = await ApiService.get('/accounts');
      _accounts = (data as List).map((item) => Account.fromJson(item)).toList();
    } catch (e) {
      // Handle error
      print(e);
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
      final newAccountData = await ApiService.post('/accounts', {
        'name': name,
        'type': type,
        'parent_type': parentType,
        'balance': balance,
      });
      final newAccount = Account.fromJson(newAccountData);
      _accounts.add(newAccount);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final updatedAccountData = await ApiService.put('/accounts/$accountId', {
        'balance': newBalance,
      });
      final updatedAccount = Account.fromJson(updatedAccountData);
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteAccount(String accountId) async {
    try {
      await ApiService.delete('/accounts/$accountId');
      _accounts.removeWhere((acc) => acc.id == accountId);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
