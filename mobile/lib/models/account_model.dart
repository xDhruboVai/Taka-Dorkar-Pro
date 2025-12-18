class Account {
  final String id;
  final String userId;
  final String name;
  final String type;
  double balance;
  final String currency;
  final String parentType;
  final bool isDefault;
  final bool includeInSavings;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.parentType,
    required this.isDefault,
    required this.includeInSavings,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      currency: json['currency'],
      parentType: json['parent_type'],
      isDefault: json['is_default'] ?? false,
      includeInSavings: json['include_in_savings'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'parent_type': parentType,
      'is_default': isDefault,
      'include_in_savings': includeInSavings,
    };
  }
}
