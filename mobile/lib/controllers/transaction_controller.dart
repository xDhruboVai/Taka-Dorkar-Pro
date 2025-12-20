import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionController with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Fetch transactions for a specific user
  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/transactions?user_id=$userId');
      if (response != null && response is List) {
        _transactions = response.map((data) => TransactionModel.fromJson(data)).toList();
      } else {
        _transactions = [];
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new transaction
  Future<bool> addTransaction(Map<String, dynamic> transactionData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/transactions', transactionData);
      // Refresh list after addition
      if (transactionData['user_id'] != null) {
        await fetchTransactions(transactionData['user_id']);
      }
      return true;
    } catch (e) {
      print("Error adding transaction: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
