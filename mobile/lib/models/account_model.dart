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
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? 'Unnamed Account',
      type: json['type'] ?? 'others',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'BDT',
      parentType: json['parent_type'] ?? json['type'] ?? 'others',
      isDefault: json['is_default'] ?? false,
      includeInSavings: json['include_in_savings'] ?? false,
    );
  }

  factory Account.fromLocalDb(Map<String, dynamic> data) {
    return Account(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      name: data['name'] as String,
      type: data['type'] as String? ?? 'others',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'BDT',
      parentType: data['parent_type'] as String? ?? data['type'] as String? ?? 'others',
      isDefault: (data['is_default'] as int?) == 1,
      includeInSavings: (data['include_in_savings'] as int?) == 1,
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
