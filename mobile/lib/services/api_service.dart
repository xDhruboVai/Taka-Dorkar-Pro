import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    return 'http://localhost:5001/api';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  static Future<dynamic> _processResponse(http.Response response) async {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      } else {
        throw Exception(
          'Server returned empty error response (Status: ${response.statusCode})',
        );
      }
    }

    dynamic jsonData;
    try {
      jsonData = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to parse server response');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw Exception(
        jsonData['error'] ?? 'Unknown Error (Status: ${response.statusCode})',
      );
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

  // Fraud Detection APIs
  static Future<dynamic> detectSpam({
    required String phoneNumber,
    required String messageText,
    required String mlPrediction,
    required double mlConfidence,
  }) async {
    return await post('/fraud/detect', {
      'phoneNumber': phoneNumber,
      'messageText': messageText,
      'mlPrediction': mlPrediction,
      'mlConfidence': mlConfidence,
    });
  }

  static Future<List<dynamic>> getSpamMessages({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final response = await get(
      '/fraud/messages?limit=$limit&offset=$offset&unreadOnly=$unreadOnly',
    );
    return response['data'] as List<dynamic>;
  }

  static Future<dynamic> getSpamStats() async {
    final response = await get('/fraud/stats');
    return response['data'];
  }

  static Future<void> markSpamAsRead(int id) async {
    await ApiService.patch('/fraud/messages/$id/read', {});
  }

  static Future<void> markSpamAsSafe(int id) async {
    await ApiService.patch('/fraud/messages/$id/safe', {});
  }

  static Future<void> deleteSpamMessage(int id) async {
    await delete('/fraud/messages/$id');
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }
}
