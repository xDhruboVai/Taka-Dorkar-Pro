class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;

  UserModel({required this.id, required this.name, required this.email, required this.role, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'free',
      token: token ?? json['token'],
    );
  }
}
