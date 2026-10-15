/// Nilai fitur dari backend bisa num ATAU String (mis. "Male"), jadi dinormalkan ke teks.
String _formatValue(dynamic v) {
  if (v is num) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
  return v.toString();
}

class ShapItem {
  final String feature;
  final String label;
  final String value;
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

  /// Backend tidak mengirim `explanation`; kalimatnya dibuat di klien.
  static String describe(String label, String value, String direction) =>
      '$label ($value) $direction risiko.';

  factory ShapItem.fromJson(Map<String, dynamic> json) {
    final label = json['label'] as String;
    final value = _formatValue(json['value']);
    final direction = json['direction'] as String;
    return ShapItem(
      feature: json['feature'] as String,
      label: label,
      value: value,
      contribution: (json['contribution'] as num).toDouble(),
      direction: direction,
      explanation:
          json['explanation'] as String? ?? describe(label, value, direction),
    );
  }
}

class PredictionResult {
  final double riskScore;
  final double probability;
  final String category;
  final String message;
  final double baseValue;
  final Map<String, double> shapValues;
  final List<ShapItem> shapBreakdown;
  final List<String> recommendations;
  final int modelVersion;
  final String modelHash;
  final String dataSource; // "real" | "synthetic"
  final String source; // "device" | "server"

  const PredictionResult({
    required this.riskScore,
    required this.probability,
    required this.category,
    required this.message,
    required this.shapValues,
    required this.shapBreakdown,
    required this.recommendations,
    this.baseValue = 0,
    this.modelVersion = 0,
    this.modelHash = '',
    this.dataSource = '',
    this.source = 'server',
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final shapRaw = (json['shap_values'] as Map<String, dynamic>? ?? {});
    return PredictionResult(
      riskScore: (json['risk_score'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      category: json['category'] as String,
      message: json['message'] as String,
      baseValue: (json['base_value'] as num?)?.toDouble() ?? 0,
      shapValues: shapRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      shapBreakdown: ((json['shap_breakdown'] as List?) ?? [])
          .map((e) => ShapItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: ((json['recommendations'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      modelVersion: (json['model_version'] as num?)?.toInt() ?? 0,
      modelHash: json['model_hash'] as String? ?? '',
      dataSource: json['data_source'] as String? ?? '',
      source: 'server',
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
  final String? photoUrl;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: (json['access_token'] ?? json['token'] ?? '') as String,
        userId: (json['user_id'] ?? json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        photoUrl: json['photo_url'] as String? ??
            json['photoUrl'] as String? ??
            json['avatar_url'] as String?,
      );
}
