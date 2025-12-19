import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionController with ChangeNotifier {
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  String _selectedPeriod = 'Current Month';

  List<TransactionModel> get transactions {
    final now = DateTime.now();
    return _allTransactions.where((tx) {
      if (_selectedPeriod == 'Today') {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      } else if (_selectedPeriod == 'Last Week') {
        final lastWeekStart = now.subtract(Duration(days: 7));
        return tx.date.isAfter(lastWeekStart) && tx.date.isBefore(now.add(Duration(days: 1)));
      } else if (_selectedPeriod == 'Current Month') {
        return tx.date.year == now.year && tx.date.month == now.month;
      }
      return true;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  double get totalIncome {
    return transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assuming 'user_id' is handled by backend via auth token or session
      final List<dynamic> data = await ApiService.get('/transactions');
      print('DEBUG: Fetched transactions: $data');
      
      _allTransactions = data.map((json) {
        print('DEBUG: Mapping transaction: $json');
        return TransactionModel.fromJson(json);
      }).toList();
      
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final response = await ApiService.post('/transactions', transaction.toJson());
      print('DEBUG: Added transaction response: $response');
      // Re-fetch or add to local list
      // _allTransactions.insert(0, TransactionModel.fromJson(response));
      // For now, simpler to re-fetch to ensure sync and sort order, 
      // but inserting locally is faster UI. Let's insert locally with server response.
      _allTransactions.insert(0, TransactionModel.fromJson(response));
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }
}



