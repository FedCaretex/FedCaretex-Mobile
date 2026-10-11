import 'dart:math';
import 'dart:typed_data';

import 'package:fedcaretex_ai/features/fl_engine/model.dart';

/// Preprocessing dan scaling data medis pasien menggunakan bounds
/// dari dataset (wajib sinkron dengan server dan paper riset).
class ClinicalData {
  static const Map<String, List<double>> featureBounds = {
    'gender': [0.0, 1.0],               // 0=Female, 1=Male
    'age': [0.0, 80.0],
    'hypertension': [0.0, 1.0],         // Boolean
    'heart_disease': [0.0, 1.0],        // Boolean
    'smoking_history': [0.0, 4.0],      // Encoded: 0..4
    'bmi': [10.0, 95.7],
    'HbA1c_level': [3.5, 9.0],
    'blood_glucose_level': [80.0, 300.0]
  };

  /// Mengubah Raw Input menjadi Normalized Float32List [0, 1]
  static Float32List scale(Map<String, double> rawFeatures) {
    if (rawFeatures.length != 8) {
      throw ArgumentError("Dibutuhkan tepat 8 fitur medis");
    }

    var keys = [
      'gender', 'age', 'hypertension', 'heart_disease', 
      'smoking_history', 'bmi', 'HbA1c_level', 'blood_glucose_level'
    ];
    
    var scaled = Float32List(8);
    for (int i = 0; i < 8; i++) {
      String key = keys[i];
      double val = rawFeatures[key] ?? 0.0;
      double minVal = featureBounds[key]![0];
      double maxVal = featureBounds[key]![1];
      
      // Min-Max Scale with clamp
      double s = (val - minVal) / (maxVal - minVal);
      scaled[i] = s.clamp(0.0, 1.0);
    }
    
    return scaled;
  }
}
