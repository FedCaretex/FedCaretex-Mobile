import 'dart:typed_data';

import '../../../models/prediction_models.dart';
import '../../fl_engine/data.dart';
import '../../fl_engine/model.dart';
import '../../fl_engine/shap.dart';
import '../../fl_sync/services/fl_sync_service.dart';

/// Inferensi + SHAP eksak DI PERANGKAT memakai model global terverifikasi.
/// Data klinis tidak dikirim ke server. Padanan `app/services/predict_service.py`.
class OnDevicePredictor {
  static const Map<String, String> _tone = {
    'Rendah': 'Hasil ini menunjukkan risiko yang masih terkelola. Tetap jaga kebiasaan sehat.',
    'Sedang': 'Ada beberapa tanda yang perlu diwaspadai. Ini bukan diagnosis, tapi layak dipantau.',
    'Tinggi': 'Skor lebih tinggi dari biasanya. Segera konsultasikan ke tenaga kesehatan, jangan panik.',
  };

  // Saran umum (bukan diagnosis); hanya untuk fitur yang MENAIKKAN risiko.
  static const Map<String, String> _recommendations = {
    'HbA1c_level':
        'Periksakan ulang HbA1c di fasilitas kesehatan (ADA: 5,7-6,4% prediabetes, >=6,5% ambang diagnosis).',
    'blood_glucose_level':
        'Kurangi gula sederhana/minuman manis dan periksakan glukosa darah puasa.',
    'bmi':
        'Turunkan berat badan bertahap; targetkan aktivitas fisik sedang +/-150 menit per minggu.',
    'hypertension': 'Kontrol tekanan darah secara rutin dan batasi asupan garam.',
    'heart_disease':
        'Lanjutkan kontrol rutin penyakit jantung dan diskusikan risiko diabetes dengan dokter.',
    'smoking_history':
        'Pertimbangkan berhenti merokok; merokok meningkatkan risiko komplikasi metabolik.',
    'age': 'Usia tidak dapat diubah; lakukan skrining gula darah secara berkala.',
  };

  static const String _disclaimer =
      'Hasil ini skrining berbasis model, bukan diagnosis medis. Konsultasikan dengan tenaga kesehatan.';

  static String categoryOf(double p, double low, double high) =>
      p < low ? 'Rendah' : (p < high ? 'Sedang' : 'Tinggi');

  static String _fmt(Object v) {
    if (v is num) {
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }
    return v.toString();
  }

  static PredictionResult predict(GlobalModel gm, ClinicalInput input) {
    final Float32List x = ClinicalData.encode(input);
    final p = MLPModel.predictProbaSingle(gm.params, x);
    final base = MLPModel.predictProbaSingle(gm.params, gm.shapBaseline);
    final phi = ExactShap.compute(gm.params, x, gm.shapBaseline);

    final items = <ShapItem>[];
    for (var i = 0; i < ClinicalData.rawFeatures.length; i++) {
      final f = ClinicalData.rawFeatures[i];
      final label = ClinicalData.featureLabelsId[f]!;
      final value = _fmt(input.rawValue(f));
      final direction = phi[i] > 0 ? 'menaikkan' : 'menurunkan';
      items.add(ShapItem(
        feature: f,
        label: label,
        value: value,
        contribution: phi[i],
        direction: direction,
        explanation: ShapItem.describe(label, value, direction),
      ));
    }
    items.sort((a, b) => b.contribution.abs().compareTo(a.contribution.abs()));

    final recs = <String>[
      for (final it in items.take(3))
        if (it.contribution > 0 && _recommendations.containsKey(it.feature))
          _recommendations[it.feature]!,
      _disclaimer,
    ];

    final category = categoryOf(p, gm.riskLow, gm.riskHigh);
    return PredictionResult(
      riskScore: double.parse((p * 100).toStringAsFixed(2)),
      probability: p,
      category: category,
      message: _tone[category]!,
      baseValue: base,
      shapValues: {for (final it in items) it.feature: it.contribution},
      shapBreakdown: items,
      recommendations: recs,
      modelVersion: gm.modelVersion,
      modelHash: gm.hash,
      dataSource: gm.dataSource,
      source: 'device',
    );
  }
}
