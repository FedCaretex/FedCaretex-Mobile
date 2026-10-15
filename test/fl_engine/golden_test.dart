import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fedcaretex_ai/features/fl_engine/serialize.dart';

void main() {
  test('Golden Hash Check: Dart Canonical Serialization = Python Canonical Serialization', () {
    // Membaca file golden_hash.json dari backend 
    // rules: w[i] = i/1057 - 0.5 (float32), i=0..1056
    
    final file = File('../FedCaretex-BackendAI/results/golden_hash.json');
    if (!file.existsSync()) {
      print("Warning: golden_hash.json not found, skipping golden test.");
      return;
    }
    
    final content = file.readAsStringSync();
    final jsonContent = jsonDecode(content);
    
    final pythonHash = jsonContent['sha256'] as String;
    
    // Generate Dart weights sesuai aturan: w[i] = i/1057 - 0.5 (float32).
    // NumPy membulatkan ke float32 dua kali: setelah pembagian, lalu setelah
    // pengurangan. Hitung dalam float64 sekaligus akan menghasilkan bit berbeda.
    final tmp = Float32List(1);
    final flat = Float32List(1057);
    for (int i = 0; i < 1057; i++) {
      tmp[0] = i / 1057.0; // dibulatkan ke float32
      flat[i] = tmp[0] - 0.5; // dibulatkan ke float32 lagi
    }
    
    final dartHash = CanonicalSerialize.hashParams(flat);
    
    print("Python Hash: $pythonHash");
    print("Dart Hash:   $dartHash");
    
    expect(dartHash, equals(pythonHash), reason: "Hash di Dart harus sama persis dengan hash Python byte-per-byte!");
  });
}
