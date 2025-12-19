import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
// hypothetical service

class TransactionController with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));
      _transactions = [
        TransactionModel(
          id: '1',
          amount: 6500,
          type: 'income',
          date: DateTime.now().subtract(Duration(days: 2)),
          category: 'Salary',
          account: 'Bank',
        ),
        TransactionModel(
          id: '2',
          amount: 2135,
          type: 'expense',
          date: DateTime.now().subtract(Duration(days: 1)),
          category: 'Groceries',
          account: 'Cash',
          note: 'Weekly shopping',
        ),
        TransactionModel(
          id: '3',
          amount: 500,
          type: 'income',
          date: DateTime.now().subtract(Duration(days: 7)),
          category: 'Pocket Money',
          account: 'Cash',
          note: 'Week 3',
        ),
        TransactionModel(
          id: '4',
          amount: 85,
          type: 'expense',
          date: DateTime.now().subtract(Duration(days: 15)),
          category: 'Transport',
          account: 'Cash',
          note: 'Rickshaw',
        ),
        TransactionModel(
            id: '5',
            amount: 250,
            type: 'expense',
            date: DateTime.now().subtract(Duration(days: 0)),
            category: 'Food & Dining',
            account: 'Rocket',
            note: 'Food Panda order')
      ];
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }
}

