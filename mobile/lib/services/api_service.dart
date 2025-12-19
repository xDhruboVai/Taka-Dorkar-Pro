import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    return 'http://localhost:5001/api';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    debugPrint('DEBUG: ApiService token: $token'); // Add this line
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  static Future<dynamic> _processResponse(http.Response response) async {
    debugPrint('API Response [${response.request?.method}] ${response.request?.url}');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {}; // Return empty map if success but no body
      } else {
        throw Exception('Server returned empty error response (Status: ${response.statusCode})');
      }
    }

    dynamic jsonData;
    try {
      jsonData = jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error decoding JSON: $e');
      throw Exception('Failed to parse server response');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw Exception(jsonData['error'] ?? 'Unknown Error (Status: ${response.statusCode})');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _processResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  static Future<void> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _processResponse(response); // This will throw with details
    }
  }
}
