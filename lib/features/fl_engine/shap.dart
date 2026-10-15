import 'dart:typed_data';

import 'data.dart';
import 'model.dart';

/// Shapley eksak atas 8 fitur asli (one-hot dikelompokkan kembali),
/// identik dengan `flsys/shap_exact.py`: 2^8 = 256 evaluasi model.
///
/// v(S): fitur di S memakai nilai x, fitur di luar S memakai `baseline`
/// (15 kolom, dikirim server lewat `shap_baseline`).
/// Sifat efisiensi: sum(phi) = f(x) - f(baseline).
class ExactShap {
  static const int m = 8;

  /// Mengembalikan phi (8 nilai, satuan probabilitas) berurutan sesuai
  /// `ClinicalData.rawFeatures`.
  static List<double> compute(
    Float32List w,
    Float32List x,
    Float32List baseline,
  ) {
    if (x.length != ClinicalData.nEncoded ||
        baseline.length != ClinicalData.nEncoded) {
      throw ArgumentError(
          'x dan baseline harus ${ClinicalData.nEncoded} kolom '
          '(dapat ${x.length} dan ${baseline.length})');
    }

    final groups = [
      for (final f in ClinicalData.rawFeatures) ClinicalData.featureGroups[f]!
    ];

    final nCoalitions = 1 << m;
    final v = List<double>.filled(nCoalitions, 0.0);
    for (var mask = 0; mask < nCoalitions; mask++) {
      final mixed = Float32List.fromList(baseline);
      for (var g = 0; g < m; g++) {
        if (((mask >> g) & 1) == 1) {
          for (final c in groups[g]) {
            mixed[c] = x[c];
          }
        }
      }
      v[mask] = MLPModel.predictProbaSingle(w, mixed);
    }

    final fact = List<double>.filled(m + 1, 1.0);
    for (var i = 1; i <= m; i++) {
      fact[i] = fact[i - 1] * i;
    }

    final phi = List<double>.filled(m, 0.0);
    for (var g = 0; g < m; g++) {
      for (var mask = 0; mask < nCoalitions; mask++) {
        if (((mask >> g) & 1) == 1) continue;
        final s = _countBits(mask);
        final weight = fact[s] * fact[m - s - 1] / fact[m];
        phi[g] += weight * (v[mask | (1 << g)] - v[mask]);
      }
    }
    return phi;
  }

  static int _countBits(int n) {
    var count = 0;
    while (n > 0) {
      count += n & 1;
      n >>= 1;
    }
    return count;
  }
}
