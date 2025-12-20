import 'dart:async';
import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class FraudDetectionService {
  static Interpreter? _interpreter;
  static Map<String, int>? _vocabulary;
  static const int maxLen = 100;
  static const Map<int, String> labelMapping = {
    0: 'normal',
    1: 'promo',
    2: 'smish'
  };

  static bool get isInitialized => _interpreter != null;

  static Completer<void>? _initCompleter;

  // Initialize the TFLite model
  static Future<void> initialize() async {
    if (_interpreter != null) return;
    
    if (_initCompleter != null) return _initCompleter!.future;
    
    _initCompleter = Completer<void>();

    try {
      print('⏳ Loading TFLite model...');
      // Load model
      _interpreter = await Interpreter.fromAsset('assets/fraud_model.tflite');
      print('✅ TFLite model loaded');

      // Load vocabulary
      final vocabJson = await rootBundle.loadString('assets/vocab.json');
      _vocabulary = Map<String, int>.from(json.decode(vocabJson));
      print('✅ Vocabulary loaded: ${_vocabulary!.length} words');
      
      _initCompleter!.complete();
    } catch (e) {
      print('❌ Error loading model: $e');
      _interpreter = null; 
      final error = e;
      _initCompleter!.completeError(error);
      _initCompleter = null;
      rethrow;
    }
  }

  // Preprocess text for model input
  static List<List<double>> _preprocessText(String text) {
    if (_vocabulary == null) {
      throw Exception('Vocabulary not loaded');
    }

    // Simple tokenization
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final List<int> sequence = [];

    for (final word in words) {
      final index = _vocabulary![word] ?? 1; // 1 is OOV token
      sequence.add(index);
    }

    // Pad or truncate to maxLen
    final List<double> padded = List.filled(maxLen, 0.0);
    for (int i = 0; i < sequence.length && i < maxLen; i++) {
      padded[i] = sequence[i].toDouble();
    }

    return [padded];
  }

  // Detect spam in SMS message
  static Future<Map<String, dynamic>> detectSpam(String messageText) async {
    if (_interpreter == null) {
      await initialize();
    }

    try {
      // Preprocess
      final input = _preprocessText(messageText);
      
      // Prepare output tensor
      final output = List.filled(1 * 3, 0.0).reshape([1, 3]);

      // Run inference
      _interpreter!.run(input, output);

      // Get prediction
      final predictions = output[0] as List<double>;
      int predictedClass = 0;
      double maxConfidence = predictions[0];

      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          predictedClass = i;
        }
      }

      final predictedLabel = labelMapping[predictedClass] ?? 'unknown';

      return {
        'prediction': predictedLabel,
        'confidence': maxConfidence,
        'isSpam': predictedLabel == 'smish',
        'threatLevel': _getThreatLevel(predictedLabel, maxConfidence),
        'allPredictions': {
          'normal': predictions[0],
          'promo': predictions[1],
          'smish': predictions[2],
        }
      };
    } catch (e) {
      print('❌ Error during inference: $e');
      return {
        'prediction': 'unknown',
        'confidence': 0.0,
        'isSpam': false,
        'threatLevel': 'low',
        'error': e.toString()
      };
    }
  }

  static String _getThreatLevel(String prediction, double confidence) {
    if (prediction == 'smish') {
      return confidence > 0.95 ? 'high' : 'medium';
    } else if (prediction == 'promo') {
      return 'low';
    }
    return 'low';
  }

  // Cleanup
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
