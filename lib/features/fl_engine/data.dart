import 'dart:typed_data';

/// 8 fitur klinis mentah (urutan & nama = `flsys/data.py::RAW_FEATURES`).
class ClinicalInput {
  final String gender; // Female | Male | Other
  final double age;
  final int hypertension; // 0 | 1
  final int heartDisease; // 0 | 1
  final String smokingHistory; // No Info | never | former | current | not current | ever
  final double bmi;
  final double hba1c;
  final double bloodGlucose;

  const ClinicalInput({
    required this.gender,
    required this.age,
    required this.hypertension,
    required this.heartDisease,
    required this.smokingHistory,
    required this.bmi,
    required this.hba1c,
    required this.bloodGlucose,
  });

  /// Nama kunci identik dengan skema `ClinicalFeatures` di backend.
  Map<String, dynamic> toJson() => {
        'gender': gender,
        'age': age,
        'hypertension': hypertension,
        'heart_disease': heartDisease,
        'smoking_history': smokingHistory,
        'bmi': bmi,
        'HbA1c_level': hba1c,
        'blood_glucose_level': bloodGlucose,
      };

  factory ClinicalInput.fromJson(Map<String, dynamic> json) => ClinicalInput(
        gender: json['gender'] as String,
        age: (json['age'] as num).toDouble(),
        hypertension: (json['hypertension'] as num).toInt(),
        heartDisease: (json['heart_disease'] as num).toInt(),
        smokingHistory: json['smoking_history'] as String,
        bmi: (json['bmi'] as num).toDouble(),
        hba1c: (json['HbA1c_level'] as num).toDouble(),
        bloodGlucose: (json['blood_glucose_level'] as num).toDouble(),
      );

  /// Nilai mentah per fitur (untuk ditampilkan di penjelasan SHAP).
  Object rawValue(String feature) {
    switch (feature) {
      case 'gender':
        return gender;
      case 'age':
        return age;
      case 'hypertension':
        return hypertension;
      case 'heart_disease':
        return heartDisease;
      case 'smoking_history':
        return smokingHistory;
      case 'bmi':
        return bmi;
      case 'HbA1c_level':
        return hba1c;
      case 'blood_glucose_level':
        return bloodGlucose;
    }
    throw ArgumentError('Fitur tidak dikenal: $feature');
  }
}

/// Prapemrosesan identik dengan `flsys/data.py::preprocess`.
///
/// Layout 15 kolom (WAJIB sama dengan `ENCODED_COLUMNS` di Python):
///   0 age | 1 bmi | 2 HbA1c | 3 glukosa              (Min-Max, batas klinis tetap, di-clip)
///   4 hypertension | 5 heart_disease                 (biner)
///   6..8  gender = Female, Male, Other               (one-hot)
///   9..14 smoking = No Info, never, former, current, not current, ever (one-hot)
class ClinicalData {
  static const int nEncoded = 15;

  static const List<String> rawFeatures = [
    'gender',
    'age',
    'hypertension',
    'heart_disease',
    'smoking_history',
    'bmi',
    'HbA1c_level',
    'blood_glucose_level',
  ];

  static const List<String> genderCats = ['Female', 'Male', 'Other'];
  static const List<String> smokingCats = [
    'No Info',
    'never',
    'former',
    'current',
    'not current',
    'ever',
  ];

  /// Batas klinis tetap (sudah diverifikasi terhadap CSV asli: 0% nilai ter-clip).
  static const Map<String, List<double>> featureBounds = {
    'age': [0.0, 100.0],
    'bmi': [10.0, 100.0],
    'HbA1c_level': [3.5, 9.0],
    'blood_glucose_level': [80.0, 300.0],
  };

  /// Fitur asli -> indeks kolom encoded (SHAP berkelompok).
  static const Map<String, List<int>> featureGroups = {
    'age': [0],
    'bmi': [1],
    'HbA1c_level': [2],
    'blood_glucose_level': [3],
    'hypertension': [4],
    'heart_disease': [5],
    'gender': [6, 7, 8],
    'smoking_history': [9, 10, 11, 12, 13, 14],
  };

  static const Map<String, String> featureLabelsId = {
    'gender': 'Jenis kelamin',
    'age': 'Usia',
    'hypertension': 'Hipertensi',
    'heart_disease': 'Penyakit jantung',
    'smoking_history': 'Riwayat merokok',
    'bmi': 'Indeks massa tubuh (BMI)',
    'HbA1c_level': 'Kadar HbA1c',
    'blood_glucose_level': 'Kadar glukosa darah',
  };

  static double _norm(String feature, double value) {
    final b = featureBounds[feature]!;
    final clipped = value.clamp(b[0], b[1]).toDouble();
    return (clipped - b[0]) / (b[1] - b[0]);
  }

  /// ClinicalInput -> vektor 15 kolom float32.
  /// Kategori tak dikenal menghasilkan one-hot nol (sama seperti Python).
  static Float32List encode(ClinicalInput x) {
    final v = Float32List(nEncoded);
    v[0] = _norm('age', x.age);
    v[1] = _norm('bmi', x.bmi);
    v[2] = _norm('HbA1c_level', x.hba1c);
    v[3] = _norm('blood_glucose_level', x.bloodGlucose);
    v[4] = x.hypertension.toDouble();
    v[5] = x.heartDisease.toDouble();
    final g = genderCats.indexOf(x.gender);
    if (g >= 0) v[6 + g] = 1.0;
    final s = smokingCats.indexOf(x.smokingHistory);
    if (s >= 0) v[9 + s] = 1.0;
    return v;
  }
}
