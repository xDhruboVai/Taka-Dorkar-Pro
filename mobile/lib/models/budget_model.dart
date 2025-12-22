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
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      return DateTime.parse(v.toString());
    }

    final isDelRaw = m['is_deleted'];
    final isDel = isDelRaw is bool
        ? isDelRaw
        : isDelRaw is num
        ? isDelRaw != 0
        : false;

    return BudgetModel(
      id: m['id']?.toString() ?? '',
      userId: m['user_id']?.toString() ?? '',
      categoryId: m['category_id']?.toString() ?? '',
      amount: (m['amount'] is num)
          ? (m['amount'] as num).toDouble()
          : double.tryParse('${m['amount']}') ?? 0.0,
      period: m['period']?.toString() ?? 'monthly',
      startDate: _parseDate(m['start_date']),
      endDate: m['end_date'] != null ? _parseDate(m['end_date']) : null,
      isDeleted: isDel,
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
