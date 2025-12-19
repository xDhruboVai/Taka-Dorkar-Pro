class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income', 'expense', or 'transfer'
  final DateTime date;
  final String category;
  final String account;
  final String? note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.account,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'Uncategorized',
      account: json['account'] ?? 'Cash',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'category': category,
      'account': account,
      'note': note,
    };
  }
}

