import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identitas klien: keypair Ed25519. client_id = SHA-256(public key) (pseudonim).
/// Klien menandatangani (round_id || hash); gateway memverifikasi sebelum menulis ke chain.
///
/// Seed 32 byte disimpan di SharedPreferences agar client_id stabil antar-sesi.
/// CATATAN: untuk produksi pindahkan ke Android Keystore / iOS Keychain
/// (mis. flutter_secure_storage); SharedPreferences tidak terenkripsi.
class Identity {
  final SimpleKeyPair keyPair;
  final List<int> publicKeyBytes;
  final String clientId;

  Identity._(this.keyPair, this.publicKeyBytes, this.clientId);

  static const String _seedKey = 'fl_identity_seed_hex';

  /// Membuat identitas deterministik dari seed 32 byte (RFC 8032).
  static Future<Identity> fromSeed(List<int> seed) async {
    if (seed.length != 32) {
      throw ArgumentError('Seed Ed25519 harus 32 byte (dapat ${seed.length})');
    }
    final keyPair = await Ed25519().newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();
    final pkBytes = publicKey.bytes;
    final digest = await Sha256().hash(pkBytes);
    return Identity._(keyPair, pkBytes, bytesToHex(digest.bytes));
  }

  /// Identitas baru dengan seed acak (tidak disimpan).
  static Future<Identity> generate() => fromSeed(_randomSeed());

  /// Memuat identitas tersimpan; bila belum ada, buat baru lalu simpan.
  static Future<Identity> loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_seedKey);
    if (stored != null && stored.length == 64) {
      try {
        return await fromSeed(hexToBytes(stored));
      } on FormatException {
        // seed rusak -> buat ulang di bawah
      }
    }
    final seed = _randomSeed();
    await prefs.setString(_seedKey, bytesToHex(seed));
    return fromSeed(seed);
  }

  static List<int> _randomSeed() {
    final rng = Random.secure();
    return List<int>.generate(32, (_) => rng.nextInt(256));
  }

  /// Format pesan: uint64_be(round_id) || bytes(hash_hex).
  /// Ditulis manual (bukan ByteData.setUint64) agar juga jalan di Flutter Web.
  static Uint8List signingMessage(int roundId, String hashHex) {
    final out = <int>[];
    final be = List<int>.filled(8, 0);
    var v = roundId;
    for (var i = 7; i >= 0; i--) {
      be[i] = v % 256;
      v = v ~/ 256;
    }
    out.addAll(be);
    out.addAll(hexToBytes(hashHex));
    return Uint8List.fromList(out);
  }

  Future<String> sign(int roundId, String hashHex) async {
    final message = signingMessage(roundId, hashHex);
    final signature = await Ed25519().sign(message, keyPair: keyPair);
    return bytesToHex(signature.bytes);
  }

  String get publicKeyHex => bytesToHex(publicKeyBytes);

  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static List<int> hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw const FormatException('Panjang hex harus genap');
    }
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
