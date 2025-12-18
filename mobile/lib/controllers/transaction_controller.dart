import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart'; // hypothetical service

class TransactionController with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));
      _transactions = [
        TransactionModel(id: '1', amount: 500, type: 'expense', date: DateTime.now()),
        TransactionModel(id: '2', amount: 12000, type: 'income', date: DateTime.now()),
      ];
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
