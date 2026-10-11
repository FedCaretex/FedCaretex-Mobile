import 'dart:typed_data';
import 'package:fedcaretex_ai/features/fl_engine/model.dart';

/// Implementasi EXACT SHAPLEY VALUES (On-Device)
/// Berhubung fitur hanya 8, kita bisa evaluasi secara persis dengan 2^8 = 256 kombinasi
/// (tanpa aproksimasi TreeSHAP / KernelSHAP).
class ExactShap {
  /// base = ekspektasi / nilai default. Di eksperimen diabetes ini kita memakai array 0
  /// atau nilai mean global (disini diasumsikan 0.0 sebagai baseline).
  static Float32List computeShap(Float32List w, Float32List x, {Float32List? baseline}) {
    final int M = 8;
    final int numCoalitions = 1 << M; // 256
    
    var base = baseline ?? Float32List(M);
    
    // Memoization table untuk prediksi f(S)
    var fS = Float64List(numCoalitions);
    for (int mask = 0; mask < numCoalitions; mask++) {
      var xCoal = Float32List(M);
      for (int i = 0; i < M; i++) {
        if ((mask & (1 << i)) != 0) {
          xCoal[i] = x[i];
        } else {
          xCoal[i] = base[i];
        }
      }
      fS[mask] = MLPModel.predictProbaSingle(w, xCoal);
    }
    
    // Hitung bobot faktorial Shapley W = |S|! (M - |S| - 1)! / M!
    var fact = List<double>.filled(M + 1, 1.0);
    for (int i = 1; i <= M; i++) {
      fact[i] = fact[i - 1] * i;
    }
    
    var weights = List<double>.filled(M, 0.0);
    for (int sSize = 0; sSize < M; sSize++) {
      weights[sSize] = (fact[sSize] * fact[M - sSize - 1]) / fact[M];
    }
    
    var shapValues = Float32List(M);
    
    for (int i = 0; i < M; i++) {
      double phi = 0.0;
      for (int mask = 0; mask < numCoalitions; mask++) {
        // Jika fitur i TIDAK ada dalam koalisi S
        if ((mask & (1 << i)) == 0) {
          int maskWithI = mask | (1 << i);
          
          // Hitung ukuran koalisi S
          int sSize = _countBits(mask);
          
          double marginalContribution = fS[maskWithI] - fS[mask];
          phi += weights[sSize] * marginalContribution;
        }
      }
      shapValues[i] = phi;
    }
    
    return shapValues;
  }
  
  static int _countBits(int n) {
    int count = 0;
    while (n > 0) {
      count += n & 1;
      n >>= 1;
    }
    return count;
  }
}
