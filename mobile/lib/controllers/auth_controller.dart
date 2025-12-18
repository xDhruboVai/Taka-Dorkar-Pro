import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      _currentUser = UserModel.fromJson(data['user'], token: data['token']);
      await _saveToken(data['token']);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.post('/auth/signup', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      _currentUser = UserModel.fromJson(data['user'], token: data['token']);
      await _saveToken(data['token']);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
