// Tes paritas Dart <-> Python (FedCaretex-BackendAI/flsys).
// Semua nilai harapan dihitung dari implementasi referensi Python:
//   results/golden_hash.json, flsys.data.preprocess, flsys.model.predict_proba,
//   flsys.shap_exact.exact_shap, flsys.identity.ClientIdentity (Ed25519).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fedcaretex_ai/features/fl_engine/data.dart';
import 'package:fedcaretex_ai/features/fl_engine/dp.dart';
import 'package:fedcaretex_ai/features/fl_engine/identity.dart';
import 'package:fedcaretex_ai/features/fl_engine/model.dart';
import 'package:fedcaretex_ai/features/fl_engine/serialize.dart';
import 'package:fedcaretex_ai/features/fl_engine/shap.dart';

const _golden =
    'de3e9a48470643a716e9a82fc841cbb560ac11f622e1ab2404da73c5b0b5f986';

/// w[i] = i/1057 - 0.5 dalam aritmetika float32 (aturan di golden_hash.json).
Float32List _goldenParams() {
  final tmp = Float32List(1);
  final w = Float32List(MLPModel.totalParams);
  for (var i = 0; i < w.length; i++) {
    tmp[0] = i / 1057.0; // dibulatkan ke float32
    w[i] = tmp[0] - 0.5; // dibulatkan ke float32 lagi
  }
  return w;
}

/// Parameter deterministik non-degenerate: w[i] = ((i*37) % 101 - 50) / 100.
Float32List _testParams() {
  final w = Float32List(MLPModel.totalParams);
  for (var i = 0; i < w.length; i++) {
    w[i] = (((i * 37) % 101) - 50) / 100.0;
  }
  return w;
}

const _sample = ClinicalInput(
  gender: 'Male',
  age: 55,
  hypertension: 1,
  heartDisease: 0,
  smokingHistory: 'former',
  bmi: 31.5,
  hba1c: 7.0,
  bloodGlucose: 180,
);

void main() {
  group('serialisasi & hash', () {
    test('hash vektor emas sama dengan Python', () {
      expect(CanonicalSerialize.hashParams(_goldenParams()), _golden);
    });

    test('hash parameter uji sama dengan Python', () {
      expect(
        CanonicalSerialize.hashParams(_testParams()),
        '9a8eeba64a71522c4e7a61bc6a47fc101e3c05a9a48f11973f2a3cf4b67febf8',
      );
    });

    test('round trip FLM1', () {
      final w = _testParams();
      final back =
          CanonicalSerialize.fromCanonicalBytes(CanonicalSerialize.toCanonicalBytes(w));
      expect(back, equals(w));
    });
  });

  group('prapemrosesan (15 kolom)', () {
    test('contoh pasien', () {
      final x = ClinicalData.encode(_sample);
      const expected = [
        0.550000011920929, 0.23888888955116272, 0.6363636255264282,
        0.4545454680919647, 1.0, 0.0, // 4 numerik + 2 biner
        0.0, 1.0, 0.0, // gender = Male
        0.0, 0.0, 1.0, 0.0, 0.0, 0.0, // smoking = former
      ];
      expect(x.length, ClinicalData.nEncoded);
      for (var i = 0; i < expected.length; i++) {
        expect(x[i], closeTo(expected[i], 1e-6), reason: 'kolom $i');
      }
    });

    test('nilai di luar batas klinis di-clip, kategori one-hot', () {
      final x = ClinicalData.encode(const ClinicalInput(
        gender: 'Other',
        age: 150,
        hypertension: 1,
        heartDisease: 0,
        smokingHistory: 'No Info',
        bmi: 5,
        hba1c: 12,
        bloodGlucose: 20,
      ));
      const expected = [
        1.0, 0.0, 1.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      ];
      for (var i = 0; i < expected.length; i++) {
        expect(x[i], closeTo(expected[i], 1e-6), reason: 'kolom $i');
      }
    });
  });

  group('model & SHAP', () {
    final w = _testParams();
    final baseline =
        Float32List.fromList([for (var j = 0; j < 15; j++) (j % 5) / 10]);

    test('probabilitas sama dengan Python', () {
      final x = ClinicalData.encode(_sample);
      expect(MLPModel.predictProbaSingle(w, x), closeTo(0.4889239966869354, 1e-5));
      expect(MLPModel.predictProbaSingle(w, baseline),
          closeTo(0.630734920501709, 1e-5));
    });

    test('SHAP eksak sama dengan Python & memenuhi efisiensi', () {
      final x = ClinicalData.encode(_sample);
      final phi = ExactShap.compute(w, x, baseline);
      // urutan = ClinicalData.rawFeatures
      const expected = [
        -0.04302718057518914, // gender
        -0.03907148057506199, // age
        -0.014704779429095115, // hypertension
        0.0, // heart_disease
        -0.06684097562517438, // smoking_history
        -0.0032531372138432098, // bmi
        0.01714721059515363, // HbA1c_level
        0.007939419008436659, // blood_glucose_level
      ];
      for (var i = 0; i < expected.length; i++) {
        expect(phi[i], closeTo(expected[i], 1e-5), reason: ClinicalData.rawFeatures[i]);
      }
      final p = MLPModel.predictProbaSingle(w, x);
      final pb = MLPModel.predictProbaSingle(w, baseline);
      expect(phi.reduce((a, b) => a + b), closeTo(p - pb, 1e-6));
    });
  });

  group('DP', () {
    test('clip L2 membatasi norma ke C', () {
      final d = Float32List.fromList([for (var i = 0; i < 1057; i++) (i % 7) - 3.0]);
      final c = DP.clipL2(d, 1.0);
      var n = 0.0;
      for (final v in c) {
        n += v * v;
      }
      expect(n, lessThanOrEqualTo(1.0 + 1e-4));
    });
  });

  group('identitas Ed25519', () {
    test('kunci, client_id, dan tanda tangan sama dengan Python', () async {
      final id = await Identity.fromSeed(List<int>.filled(32, 1));
      expect(id.publicKeyHex,
          '8a88e3dd7409f195fd52db2d3cba5d72ca6709bf1d94121bf3748801b40f6f5c');
      expect(id.clientId,
          '34750f98bd59fcfc946da45aaabe933be154a4b5094e1c4abf42866505f3c97e');
      expect(
        await id.sign(5, _golden),
        '20db03713caeb72c2eb82c9f66b206d11e23b6110a45be2c8dc9a2ee2609f989'
        '03b9a94eb437f25265de235702741b9499753c9814696683a609dd5e78424f0e',
      );
    });

    test('pesan = uint64 big-endian || hash', () {
      final m = Identity.signingMessage(5, _golden);
      expect(m.sublist(0, 8), [0, 0, 0, 0, 0, 0, 0, 5]);
      expect(m.length, 8 + 32);
    });
  });
}
