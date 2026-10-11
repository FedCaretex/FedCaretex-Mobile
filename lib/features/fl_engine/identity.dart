import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Identitas klien: keypair Ed25519. client_id = SHA-256(public key) (pseudonim).
/// Klien menandatangani (round_id || hash); gateway memverifikasi sebelum menulis ke chain.
class Identity {
  final SimpleKeyPair keyPair;
  final List<int> publicKeyBytes;
  final String clientId;

  Identity._(this.keyPair, this.publicKeyBytes, this.clientId);

  static Future<Identity> generate() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = publicKey.bytes;
    
    // clientId = sha256(publicKey)
    final digest = await Sha256().hash(publicKeyBytes);
    final clientId = _bytesToHex(digest.bytes);
    
    return Identity._(keyPair, publicKeyBytes, clientId);
  }
  
  // Format pesan: uint64_be(round_id) || bytes(hash_hex)
  static Uint8List _msg(int roundId, String hashHex) {
    final byteData = ByteData(8);
    byteData.setUint64(0, roundId, Endian.big);
    
    final hashBytes = _hexToBytes(hashHex);
    
    final b = BytesBuilder();
    b.add(byteData.buffer.asUint8List());
    b.add(hashBytes);
    return b.toBytes();
  }

  Future<String> sign(int roundId, String hashHex) async {
    final message = _msg(roundId, hashHex);
    final algorithm = Ed25519();
    final signature = await algorithm.sign(message, keyPair: keyPair);
    return _bytesToHex(signature.bytes);
  }
  
  String get publicKeyHex => _bytesToHex(publicKeyBytes);

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
