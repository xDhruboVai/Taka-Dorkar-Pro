class SpamMessage {
  final int? id;
  final String userId;
  final String phoneNumber;
  final String messageText;
  final String detectionMethod; // 'ml', 'ai', 'both'
  final String threatLevel; // 'low', 'medium', 'high'
  final double? aiConfidence;
  final double? mlConfidence;
  final DateTime detectedAt;
  final bool isRead;
  final bool isFalsePositive;

  SpamMessage({
    this.id,
    required this.userId,
    required this.phoneNumber,
    required this.messageText,
    required this.detectionMethod,
    required this.threatLevel,
    this.aiConfidence,
    this.mlConfidence,
    required this.detectedAt,
    this.isRead = false,
    this.isFalsePositive = false,
  });

  factory SpamMessage.fromJson(Map<String, dynamic> json) {
    return SpamMessage(
      id: json['id'],
      userId: json['user_id'],
      phoneNumber: json['phone_number'],
      messageText: json['message_text'],
      detectionMethod: json['detection_method'],
      threatLevel: json['threat_level'],
      aiConfidence: json['ai_confidence']?.toDouble(),
      mlConfidence: json['ml_confidence']?.toDouble(),
      detectedAt: DateTime.parse(json['detected_at']),
      isRead: json['is_read'] ?? false,
      isFalsePositive: json['is_false_positive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone_number': phoneNumber,
      'message_text': messageText,
      'detection_method': detectionMethod,
      'threat_level': threatLevel,
      'ai_confidence': aiConfidence,
      'ml_confidence': mlConfidence,
      'detected_at': detectedAt.toIso8601String(),
      'is_read': isRead,
      'is_false_positive': isFalsePositive,
    };
  }
}

class SecurityStats {
  final int total;
  final int unread;
  final int highThreat;
  final int mediumThreat;
  final int lowThreat;
  final int today;
  final int thisWeek;

  SecurityStats({
    required this.total,
    required this.unread,
    required this.highThreat,
    required this.mediumThreat,
    required this.lowThreat,
    required this.today,
    required this.thisWeek,
  });

  factory SecurityStats.fromJson(Map<String, dynamic> json) {
    return SecurityStats(
      total: int.parse(json['total'].toString()),
      unread: int.parse(json['unread'].toString()),
      highThreat: int.parse(json['high_threat'].toString()),
      mediumThreat: int.parse(json['medium_threat'].toString()),
      lowThreat: int.parse(json['low_threat'].toString()),
      today: int.parse(json['today'].toString()),
      thisWeek: int.parse(json['this_week'].toString()),
    );
  }
}
