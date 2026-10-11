import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Serialisasi KANONIK + hash. Harus identik byte-per-byte dengan Python (flsys/serialize.py).
///
/// Format: magic "FLM1" (4 byte ASCII) | n (uint32 little-endian) | n x float32 little-endian.
/// Urutan parameter = urutan flat model.py (W1, b1, W2, b2, W3, b3; W row-major).
/// Hash = SHA-256 atas seluruh byte tersebut.
class CanonicalSerialize {
  static const List<int> magic = [70, 76, 77, 49]; // "FLM1"

  /// Mengubah list float32 (array dari bobot model) ke bytes kanonikal
  static Uint8List toCanonicalBytes(Float32List flat) {
    // 4 bytes for MAGIC + 4 bytes for array length + 4 bytes for each element
    int totalBytes = 8 + (flat.length * 4);
    var byteData = ByteData(totalBytes);

    // Write MAGIC "FLM1"
    for (int i = 0; i < 4; i++) {
      byteData.setUint8(i, magic[i]);
    }

    // Write length (uint32 little-endian)
    byteData.setUint32(4, flat.length, Endian.little);

    // Write array elements (float32 little-endian)
    for (int i = 0; i < flat.length; i++) {
      byteData.setFloat32(8 + (i * 4), flat[i], Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  /// Mengubah bytes kanonikal ke array float32
  static Float32List fromCanonicalBytes(Uint8List bytes) {
    if (bytes.length < 8) {
      throw FormatException("Header payload tidak valid (terlalu pendek)");
    }
    
    // Check MAGIC
    for (int i = 0; i < 4; i++) {
      if (bytes[i] != magic[i]) {
        throw FormatException("Header payload tidak valid (bukan FLM1)");
      }
    }

    var byteData = ByteData.sublistView(bytes);
    
    // Read length
    int n = byteData.getUint32(4, Endian.little);
    if (bytes.length != 8 + 4 * n) {
      throw FormatException("Panjang payload tidak cocok dengan header");
    }

    // Read elements
    var flat = Float32List(n);
    for (int i = 0; i < n; i++) {
      flat[i] = byteData.getFloat32(8 + (i * 4), Endian.little);
    }
    
    return flat;
  }

  /// Menghitung hash SHA-256 (hex) dari byte data
  static String sha256Hex(Uint8List bytes) {
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash params array
  static String hashParams(Float32List flat) {
    return sha256Hex(toCanonicalBytes(flat));
  }
}
