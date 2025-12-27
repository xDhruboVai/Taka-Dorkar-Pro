import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' show log;

class GeminiService {
  static const String _apiKey = 'AIzaSyABCmvGHDYZn4EtHq5vo5BbVXn3PkHOegQ';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Future<Map<String, dynamic>> analyzeSms(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      """
You are a cybersecurity expert specializing in SMS fraud detection for Bangladesh. 
Analyze the following SMS message and classify it.
The message may be in Bangla or English.

Message: "$message"

Return ONLY a JSON object with the following fields:
- isSpam: boolean (true if fraud/scam/phishing, false if normal/promo)
- type: string ("smishing", "promo", "normal", "otp", "transaction")
- threatLevel: string ("high", "medium", "low")
- confidence: float (0.0 to 1.0)
- reason: string (short explanation in English)

JSON:
""",
                },
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 256,
            "responseMimeType": "application/json",
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          final cleanContent = content
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          return jsonDecode(cleanContent);
        }
      }
      log('Gemini API Error: ${response.statusCode} - ${response.body}');
      return {};
    } catch (e) {
      log('Gemini Exception: $e');
      return {};
    }
  }
}
