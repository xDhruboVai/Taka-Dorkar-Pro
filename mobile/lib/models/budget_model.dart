class BudgetModel {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isDeleted;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isDeleted = false,
  });

  static BudgetModel fromLocal(Map<String, dynamic> m) {
    return BudgetModel(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      categoryId: m['category_id'] as String,
      amount: (m['amount'] as num).toDouble(),
      period: m['period'] as String,
      startDate: DateTime.parse(m['start_date'] as String),
      endDate: m['end_date'] != null
          ? DateTime.parse(m['end_date'] as String)
          : null,
      isDeleted: (m['is_deleted'] as int?) == 1,
    );
  }

  Map<String, dynamic> toLocal() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}
