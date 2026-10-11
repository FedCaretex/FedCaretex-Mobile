import 'dart:math';
import 'dart:typed_data';

/// Differential Privacy (DP) Logic untuk Federated Learning.
class DP {
  /// Memotong (clip) norm-L2 dari vektor gradien ke `clipNorm`
  static Float32List clipL2(Float32List update, double clipNorm) {
    double l2 = 0.0;
    for (int i = 0; i < update.length; i++) {
      l2 += update[i] * update[i];
    }
    l2 = sqrt(l2);

    var clipped = Float32List.fromList(update);
    if (l2 > clipNorm) {
      double scale = clipNorm / l2;
      for (int i = 0; i < clipped.length; i++) {
        clipped[i] *= scale;
      }
    }
    return clipped;
  }

  /// Menambahkan Gaussian Noise N(0, (noiseMultiplier * clipNorm)^2)
  static Float32List addGaussianNoise(Float32List update, double noiseMultiplier, double clipNorm) {
    if (noiseMultiplier <= 0) return update;

    double stddev = noiseMultiplier * clipNorm;
    var rand = Random();
    var noisy = Float32List.fromList(update);
    
    for (int i = 0; i < noisy.length; i++) {
      // Box-Muller transform untuk Gaussian N(0,1)
      double u1 = rand.nextDouble();
      double u2 = rand.nextDouble();
      if (u1 <= 1e-10) u1 = 1e-10; // menghindari log(0)
      
      double z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
      noisy[i] += z0 * stddev;
    }
    
    return noisy;
  }

  /// Eksekusi penuh algoritma DP-SGD untuk update lokal
  /// `deltaW` adalah update bobot (w_local - w_global)
  static Float32List applyDP(Float32List deltaW, double clipNorm, double noiseMultiplier) {
    var clipped = clipL2(deltaW, clipNorm);
    var noisy = addGaussianNoise(clipped, noiseMultiplier, clipNorm);
    return noisy;
  }
}
