import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class BudgetController extends ChangeNotifier {
  List<BudgetModel> budgets = [];
  final Map<String, double> _spent = {};
  List<Map<String, dynamic>> expenseCategories = [];
  bool isLoading = false;
  bool isBusy = false;
  DateTime currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  String? _userId;

  Future<void> initialize(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    await _ensureUser(context);
    await _loadCategories();
    await loadBudgets();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _ensureUser(BuildContext context) async {
    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      _userId = auth.currentUser?.id;
    } catch (_) {
      _userId = null;
    }
  }

  Future<void> _loadCategories() async {
    final uid = _userId;
    try {
      final data = await ApiService.get(
        '/categories?user_id=$uid&type=expense',
      );
      if (data is List) {
        expenseCategories = List<Map<String, dynamic>>.from(data);
      } else {
        expenseCategories = [];
      }
    } catch (e) {
      expenseCategories = [];
    }
  }

  Future<void> loadBudgets() async {
    final uid = _userId;
    try {
      final month =
          '${currentMonth.year.toString().padLeft(4, '0')}-${currentMonth.month.toString().padLeft(2, '0')}';
      final rows = await ApiService.get('/budgets?user_id=$uid&month=$month');
      if (rows is List) {
        budgets = rows
            .map((e) => BudgetModel.fromLocal(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        budgets = [];
      }
    } catch (_) {
      budgets = [];
    }

    // compute spent per category from server transactions
    _spent.clear();
    for (final b in budgets) {
      final name = categoryName(b.categoryId);
      final start = DateTime(currentMonth.year, currentMonth.month, 1);
      final end = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      double total = 0.0;
      if (name != null) {
        try {
          final qs = Uri(
            queryParameters: {
              'user_id': uid ?? '',
              'type': 'expense',
              'category': name,
              'from': start.toIso8601String(),
              'to': end.toIso8601String(),
            },
          ).query;
          final tx = await ApiService.get('/transactions?$qs');
          if (tx is List) {
            for (final t in tx) {
              final m = Map<String, dynamic>.from(t);
              final amt = (m['amount'] is num)
                  ? (m['amount'] as num).toDouble()
                  : double.tryParse('${m['amount']}') ?? 0.0;
              total += amt;
            }
          }
        } catch (_) {}
      }
      _spent[b.categoryId] = total;
    }
    notifyListeners();
  }

  void previousMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    loadBudgets();
  }

  void nextMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    loadBudgets();
  }

  Future<bool> createBudget({
    required String categoryId,
    required double amount,
  }) async {
    isBusy = true;
    notifyListeners();
    final uid = _userId;
    if (uid == null) {
      isBusy = false;
      notifyListeners();
      return false;
    }

    final id = const Uuid().v4();
    final startDate = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    ).toIso8601String().substring(0, 10);
    try {
      await ApiService.post('/budgets', {
        'id': id,
        'user_id': uid,
        'category_id': categoryId,
        'amount': amount,
        'period': 'monthly',
        'start_date': startDate,
      });
    } catch (e) {
      debugPrint('Failed to create budget: $e');
      isBusy = false;
      notifyListeners();
      return false;
    }
    await loadBudgets();
    isBusy = false;
    notifyListeners();
    return true;
  }

  Future<void> updateBudgetAmount(String id, double amount) async {
    isBusy = true;
    notifyListeners();
    try {
      await ApiService.patch('/budgets/$id', {'amount': amount});
    } catch (e) {
      // TODO: enqueue offline
    }
    await loadBudgets();
    isBusy = false;
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    isBusy = true;
    notifyListeners();
    try {
      await ApiService.patch('/budgets/$id', {'is_deleted': true});
    } catch (e) {
      // TODO: enqueue offline
    }
    await loadBudgets();
    isBusy = false;
    notifyListeners();
  }

  double spentFor(String categoryId) => _spent[categoryId] ?? 0.0;

  String? categoryName(String categoryId) {
    final m = expenseCategories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {},
    );
    return m.isEmpty ? null : m['name'] as String;
  }
}
