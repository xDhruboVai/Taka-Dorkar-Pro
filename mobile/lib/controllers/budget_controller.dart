import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../services/local_database.dart';
import '../controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class BudgetController extends ChangeNotifier {
  final db = LocalDatabase.instance;
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
    final uid = _userId ?? 'current_user';
    // Ensure this user has defaults
    await db.ensureExpenseCategoriesForUser(uid);
    expenseCategories = await db.getExpenseCategories(uid);
  }

  Future<void> loadBudgets() async {
    final uid = _userId ?? 'current_user';
    final rows = await db.getBudgetsForMonth(uid, currentMonth);
    budgets = rows.map(BudgetModel.fromLocal).toList();
    _spent.clear();
    for (final b in budgets) {
      _spent[b.categoryId] = await db.getSpentForCategoryMonth(
        uid,
        b.categoryId,
        currentMonth,
      );
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

  Future<void> createBudget({
    required String categoryId,
    required double amount,
  }) async {
    isBusy = true;
    notifyListeners();
    final uid = _userId ?? 'current_user';
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    final data = {
      'id': id,
      'user_id': uid,
      'category_id': categoryId,
      'amount': amount,
      'period': 'monthly',
      'start_date': DateTime(
        currentMonth.year,
        currentMonth.month,
        1,
      ).toIso8601String(),
      'end_date': null,
      'created_at': now,
      'updated_at': now,
      'server_updated_at': null,
      'is_deleted': 0,
      'local_updated_at': now,
      'needs_sync': 1,
    };
    await db.insertBudget(data);
    await loadBudgets();
    isBusy = false;
    notifyListeners();
  }

  Future<void> updateBudgetAmount(String id, double amount) async {
    isBusy = true;
    notifyListeners();
    await db.updateBudgetAmount(id, amount);
    await loadBudgets();
    isBusy = false;
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    isBusy = true;
    notifyListeners();
    await db.softDeleteBudget(id);
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
