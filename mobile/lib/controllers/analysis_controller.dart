import 'package:flutter/foundation.dart';
import 'package:mobile/models/transaction_model.dart';
import 'package:mobile/models/account_model.dart';

enum TimeRange { daily, weekly, monthly }

class AnalysisController with ChangeNotifier {
  TimeRange _range = TimeRange.monthly;
  TimeRange get range => _range;

  List<TransactionModel> _transactions = [];
  List<Account> _accounts = [];

  // Aggregates
  Map<DateTime, double> _expenseTrend = {};
  Map<String, double> _categoryBreakdown = {};
  double _incomeTotal = 0;
  double _expenseTotal = 0;
  double _savingsTotal = 0;
  double _spendableTotal = 0;
  double _netTotal = 0;
  double _avgDailyExpense = 0;
  int _daysCount = 0;

  Map<DateTime, double> get expenseTrend => _expenseTrend;
  Map<String, double> get categoryBreakdown => _categoryBreakdown;
  double get incomeTotal => _incomeTotal;
  double get expenseTotal => _expenseTotal;
  double get savingsTotal => _savingsTotal;
  double get spendableTotal => _spendableTotal;
  double get netTotal => _netTotal;
  double get averageDailyExpense => _avgDailyExpense;
  int get daysCount => _daysCount;

  void setRange(TimeRange range) {
    if (_range == range) return;
    _range = range;
    _compute();
    notifyListeners();
  }

  void updateData({
    required List<TransactionModel> transactions,
    required List<Account> accounts,
  }) {
    _transactions = transactions;
    _accounts = accounts;
    _compute();
    notifyListeners();
  }

  void _compute() {
    _computeBalances();
    _computeIncomeExpenseTotals();
    _computeExpenseTrend();
    _computeCategoryBreakdown();
    _computeDerivedMetrics();
  }

  bool _isInRange(DateTime d, DateTime now) {
    final diffDays = now.difference(d).inDays;
    switch (_range) {
      case TimeRange.daily:
        return d.year == now.year && d.month == now.month && d.day == now.day;
      case TimeRange.weekly:
        return diffDays >= 0 && diffDays < 7;
      case TimeRange.monthly:
        return d.year == now.year && d.month == now.month;
    }
  }

  List<DateTime> _rangeDays(DateTime now) {
    final List<DateTime> days = [];
    switch (_range) {
      case TimeRange.daily:
        days.add(DateTime(now.year, now.month, now.day));
        break;
      case TimeRange.weekly:
        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          days.add(DateTime(d.year, d.month, d.day));
        }
        break;
      case TimeRange.monthly:
        final end = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(days: 1));
        for (int i = 0; i < end.day; i++) {
          final d = DateTime(now.year, now.month, i + 1);
          days.add(d);
        }
        break;
    }
    return days;
  }

  void _computeBalances() {
    _savingsTotal = 0;
    _spendableTotal = 0;
    for (final a in _accounts) {
      if (a.parentType == 'savings' || a.includeInSavings) {
        _savingsTotal += a.balance;
      } else {
        _spendableTotal += a.balance;
      }
    }
  }

  void _computeIncomeExpenseTotals() {
    _incomeTotal = 0;
    _expenseTotal = 0;
    final now = DateTime.now();
    for (final t in _transactions) {
      final d = t.date.toLocal();
      if (!_isInRange(d, now)) continue;
      if (t.type == 'income') _incomeTotal += t.amount;
      if (t.type == 'expense') _expenseTotal += t.amount;
    }
    _netTotal = _incomeTotal - _expenseTotal;
  }

  void _computeExpenseTrend() {
    _expenseTrend = {};
    final now = DateTime.now();
    final days = _rangeDays(now);
    for (final day in days) {
      _expenseTrend[day] = 0;
    }
    for (final t in _transactions) {
      if (t.type != 'expense') continue;
      final d = t.date.toLocal();
      if (!_isInRange(d, now)) continue;
      final key = DateTime(d.year, d.month, d.day);
      _expenseTrend[key] = (_expenseTrend[key] ?? 0) + t.amount;
    }
  }

  void _computeCategoryBreakdown() {
    _categoryBreakdown = {};
    final now = DateTime.now();
    final Map<String, double> raw = {};
    for (final t in _transactions) {
      if (t.type != 'expense') continue;
      final d = t.date.toLocal();
      if (!_isInRange(d, now)) continue;
      final cat = t.category ?? 'Uncategorized';
      raw[cat] = (raw[cat] ?? 0) + t.amount;
    }
    final entries = raw.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // Group small categories into 'Other' if too many
    const maxCats = 6;
    if (entries.length <= maxCats) {
      _categoryBreakdown = Map.fromEntries(entries);
    } else {
      final top = entries.take(maxCats).toList();
      final otherSum = entries
          .skip(maxCats)
          .fold<double>(0, (s, e) => s + e.value);
      _categoryBreakdown = {
        for (final e in top) e.key: e.value,
        'Other': otherSum,
      };
    }
  }

  void _computeDerivedMetrics() {
    final now = DateTime.now();
    final days = _rangeDays(now);
    _daysCount = days.length;
    if (_daysCount > 0) {
      _avgDailyExpense = _expenseTotal / _daysCount;
    } else {
      _avgDailyExpense = 0;
    }
  }
}
