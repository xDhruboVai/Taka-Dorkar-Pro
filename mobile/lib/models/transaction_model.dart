class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;

  TransactionModel({required this.id, required this.amount, required this.type, required this.date});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
