import 'dart:math';
import 'dart:typed_data';

/// Implementasi murni Dart dari MLP (15 -> 32 -> 16 -> 1) tanpa dependensi TFLite.
/// Harus identik secara matematis dengan `flsys/model.py`.
class MLPModel {
  static const List<int> layers = [15, 32, 16, 1];
  static const int inputDim = 15;
  static const int totalParams = 1057; // 15*32+32 + 32*16+16 + 16*1+1 = 512 + 528 + 17 = 1057

  /// Forward pass untuk satu record.
  /// Mengembalikan probabilitas.
  static double predictProbaSingle(Float32List flat, Float32List x) {
    if (flat.length != totalParams) {
      throw ArgumentError("Jumlah parameter harus $totalParams, dapat ${flat.length}");
    }

    if (x.length != inputDim) {
      throw ArgumentError("Input harus $inputDim kolom (hasil ClinicalData.encode), dapat ${x.length}");
    }
    var h = Float32List.fromList(x);
    int offset = 0;

    for (int l = 0; l < layers.length - 1; l++) {
      int inDim = layers[l];
      int outDim = layers[l + 1];

      var nextH = Float32List(outDim);
      for (int outIdx = 0; outIdx < outDim; outIdx++) {
        double z = 0.0;
        for (int inIdx = 0; inIdx < inDim; inIdx++) {
          z += h[inIdx] * flat[offset + inIdx * outDim + outIdx];
        }
        z += flat[offset + inDim * outDim + outIdx]; // Bias
        
        // ReLU for hidden layers, Sigmoid for output
        if (l < layers.length - 2) {
          nextH[outIdx] = z > 0 ? z : 0.0; // ReLU
        } else {
          // Sigmoid with clipping
          double clippedZ = z.clamp(-40.0, 40.0).toDouble();
          nextH[outIdx] = 1.0 / (1.0 + exp(-clippedZ));
        }
      }
      h = nextH;
      offset += inDim * outDim + outDim;
    }
    
    return h[0];
  }

  /// Minibatch SGD dengan FedProx
  static Float32List trainLocal({
    required Float32List wGlobal, // Model dari server
    required List<Float32List> X, // Batch data fitur
    required List<double> y,      // Target
    required int epochs,
    required double lr,
    required int batchSize,
    required double proxMu,
    int? seed,
  }) {
    var w = Float32List.fromList(wGlobal);
    var rand = seed == null ? Random() : Random(seed);
    
    int nPos = y.where((v) => v > 0.5).length;
    int nNeg = y.length - nPos;
    double posWeight = 1.0;
    if (nPos > 0) {
      posWeight = (nNeg / nPos).clamp(1.0, 20.0).toDouble();
    }

    for (int epoch = 0; epoch < epochs; epoch++) {
      // Shuffle indices
      var indices = List<int>.generate(y.length, (i) => i);
      indices.shuffle(rand);

      for (int s = 0; s < y.length; s += batchSize) {
        int e = (s + batchSize < y.length) ? s + batchSize : y.length;
        var batchIndices = indices.sublist(s, e);
        
        // Gradient accumulator
        var grads = Float32List(totalParams);
        
        for (int idx in batchIndices) {
          var xi = X[idx];
          var yi = y[idx];
          
          // FORWARD PASS dengan menyimpan nilai pre-aktivasi (z) dan post-aktivasi (a)
          List<Float32List> acts = [xi];
          List<Float32List> pres = [];
          
          var h = xi;
          int offset = 0;
          for (int l = 0; l < layers.length - 1; l++) {
            int inDim = layers[l];
            int outDim = layers[l + 1];

            var nextH = Float32List(outDim);
            var preZ = Float32List(outDim);
            
            for (int outIdx = 0; outIdx < outDim; outIdx++) {
              double z = 0.0;
              for (int inIdx = 0; inIdx < inDim; inIdx++) {
                z += h[inIdx] * w[offset + inIdx * outDim + outIdx];
              }
              z += w[offset + inDim * outDim + outIdx]; // Bias
              preZ[outIdx] = z;
              
              if (l < layers.length - 2) {
                nextH[outIdx] = z > 0 ? z : 0.0;
              } else {
                double clippedZ = z.clamp(-40.0, 40.0).toDouble();
                nextH[outIdx] = 1.0 / (1.0 + exp(-clippedZ));
              }
            }
            pres.add(preZ);
            acts.add(nextH);
            h = nextH;
            offset += inDim * outDim + outDim;
          }
          
          // BACKWARD PASS
          double p = acts.last[0];
          double weight = (yi > 0.5) ? posWeight : 1.0;
          
          // Loss derivative w.r.t pre-activation logit
          double dz = weight * (p - yi) / batchIndices.length;
          var curDz = Float32List(1);
          curDz[0] = dz;
          
          int backOffset = totalParams;
          for (int l = layers.length - 2; l >= 0; l--) {
            int inDim = layers[l];
            int outDim = layers[l + 1];
            backOffset -= (inDim * outDim + outDim);
            
            var prevActs = acts[l];
            var nextDz = Float32List(inDim); // dL / dA_{l-1}
            
            // Gradients for this layer
            for (int outIdx = 0; outIdx < outDim; outIdx++) {
              double deltaZ = curDz[outIdx];
              
              // Gradient Bias
              grads[backOffset + inDim * outDim + outIdx] += deltaZ;
              
              // Gradient Weights & next layer delta
              for (int inIdx = 0; inIdx < inDim; inIdx++) {
                grads[backOffset + inIdx * outDim + outIdx] += prevActs[inIdx] * deltaZ;
                nextDz[inIdx] += w[backOffset + inIdx * outDim + outIdx] * deltaZ;
              }
            }
            
            if (l > 0) {
              // Backward through ReLU
              var curPre = pres[l - 1];
              for (int inIdx = 0; inIdx < inDim; inIdx++) {
                if (curPre[inIdx] <= 0) {
                  nextDz[inIdx] = 0.0;
                }
              }
            }
            curDz = nextDz;
          }
        }
        
        // UPDATE WEIGHTS (FedProx if proxMu > 0)
        for (int i = 0; i < totalParams; i++) {
          double g = grads[i];
          if (proxMu > 0) {
            g += proxMu * (w[i] - wGlobal[i]);
          }
          w[i] -= lr * g;
        }
      }
    }
    
    return w;
  }
}
