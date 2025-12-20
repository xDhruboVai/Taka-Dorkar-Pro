class TransactionModel {
  final int id; // Changed to int to match SERIAL in PG
  final String userId; // Changed to String to match UUID
  final String? accountId; // Changed to String to support UUIDs
  final double amount;
  final String type; // 'income', 'expense', 'transfer'
  final String? category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.userId,
    this.accountId,
    required this.amount,
    required this.type,
    this.category,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'].toString(), // Ensure String
      accountId: json['account_id']?.toString(), // Ensure String
      amount: double.parse(json['amount'].toString()), // Ensure double
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
