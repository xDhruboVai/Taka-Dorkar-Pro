import 'dart:async';
import 'dart:developer' show log;

class FraudDetectionService {
  static Future<void> initialize() async {
    log('✅ FraudDetectionService initialized (Local Mode)');
  }

  static Future<Map<String, dynamic>> detectSpam(String messageText) async {
    log(
      '🔍 Analyzing locally: "${messageText.length > 20 ? '${messageText.substring(0, 20)}...' : messageText}"',
    );
    return _localHeuristicCheck(messageText);
  }

  static Map<String, dynamic> _localHeuristicCheck(String text) {
    final lowerText = text.toLowerCase();

    final smishKeywords = [
      'urgent',
      'verify',
      'account',
      'suspended',
      'click',
      'link',
      'bank',
      'alert',
      'update',
      'blocked',
      'deactivated',
      'winner',
      'won',
      'prize',
      'lottery',
      'claim',
      'password',
      'otp',
      'pin',
      'cvv',
      'expire',
      'unusual',
      'activity',
      'জরুরী',
      'বন্ধ',
      'অ্যাকাউন্ট',
      'সমস্যা',
      'যাচাই',
      'ক্লিক',
      'লিংক',
      'পুরস্কার',
      'পুরস্ক',
      'অভিনন্দন',
      'জিতেছেন',
      'জিত',
      'লটারি',
      'বিকাশ',
      'নগদ',
      'রকেট',
      'অফিস',
      'হেল্পলাইন',
      'পাসওয়ার্ড',
      'পিন',
      'মেয়াদ',
      'নম্বর',
      'ক্লিক করুন',
    ];

    final promoKeywords = [
      'offer',
      'discount',
      'sale',
      'flat',
      'off',
      'code',
      'promo',
      'cashback',
      'deal',
      'shop',
      'buy',
      'get',
      'free',
      'অফার',
      'ছাড়',
      'ডিসকাউন্ট',
      'ক্যাশব্যাক',
      'ডিল',
      'কিনুন',
      'ফ্রি',
      'মাত্র',
    ];

    int smishCount = 0;
    int promoCount = 0;

    for (var k in smishKeywords) {
      if (lowerText.contains(k)) smishCount++;
    }
    for (var k in promoKeywords) {
      if (lowerText.contains(k)) promoCount++;
    }

    final hasLink = RegExp(
      r'http[s]?://|www\.|bit\.ly|goo\.gl|tinyurl|t\.co|is\.gd|buff\.ly|ow\.ly',
    ).hasMatch(lowerText);
    final hasPhone = RegExp(r'(\+88)?01[3-9][0-9]{8}').hasMatch(lowerText);
    final hasMoney = RegExp(r'tk|taka|bdt|\$|৳').hasMatch(lowerText);
    final mentionsNumber = lowerText.contains('নম্বর');

    if (hasLink && smishCount > 0) {
      return {
        'isSpam': true,
        'prediction': 'smish',
        'confidence': 0.95,
        'threatLevel': 'high',
        'reason': 'Contains suspicious link and urgent keywords',
      };
    }

    if (smishCount >= 2 || (smishCount >= 1 && (hasPhone || mentionsNumber))) {
      return {
        'isSpam': true,
        'prediction': 'smish',
        'confidence': 0.85,
        'threatLevel': 'high',
        'reason': 'Security keywords with phone/number indicators',
      };
    }

    if (hasLink && (hasMoney || promoCount > 0)) {
      return {
        'isSpam': true,
        'prediction': 'promo',
        'confidence': 0.85,
        'threatLevel': 'medium',
        'reason': 'Promotional content with link detected',
      };
    }

    if (promoCount >= 1) {
      return {
        'isSpam': true,
        'prediction': 'promo',
        'confidence': 0.8,
        'threatLevel': 'low',
        'reason': 'Promotional content detected',
      };
    }

    return {
      'isSpam': false,
      'prediction': 'normal',
      'confidence': 0.7,
      'threatLevel': 'low',
      'reason': 'No threats detected',
    };
  }

  static void dispose() {}
}
