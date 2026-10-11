class ShapItem {
  final String feature;
  final String label;
  final double value;
  final double contribution;
  final String direction;
  final String explanation;

  const ShapItem({
    required this.feature,
    required this.label,
    required this.value,
    required this.contribution,
    required this.direction,
    required this.explanation,
  });

  factory ShapItem.fromJson(Map<String, dynamic> json) => ShapItem(
        feature: json['feature'] as String,
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
        contribution: (json['contribution'] as num).toDouble(),
        direction: json['direction'] as String,
        explanation: json['explanation'] as String,
      );
}

class PredictionResult {
  final double riskScore;
  final double probability;
  final String category;
  final String message;
  final Map<String, double> shapValues;
  final List<ShapItem> shapBreakdown;
  final List<String> recommendations;

  const PredictionResult({
    required this.riskScore,
    required this.probability,
    required this.category,
    required this.message,
    required this.shapValues,
    required this.shapBreakdown,
    required this.recommendations,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final shapRaw = (json['shap_values'] as Map<String, dynamic>? ?? {});
    return PredictionResult(
      riskScore: (json['risk_score'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      category: json['category'] as String,
      message: json['message'] as String,
      shapValues: shapRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      shapBreakdown: ((json['shap_breakdown'] as List?) ?? [])
          .map((e) => ShapItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: ((json['recommendations'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class HistoryItem {
  final String id;
  final String category;
  final double riskScore;
  final String topFeature;
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.category,
    required this.riskScore,
    required this.topFeature,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        category: json['category'] as String,
        riskScore: (json['risk_score'] as num).toDouble(),
        topFeature: json['top_feature'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          ((json['timestamp'] as num).toDouble() * 1000).round(),
        ),
      );
}

class AuthSession {
  final String token;
  final String userId;
  final String name;
  final String email;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['access_token'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );
}
