import 'dart:typed_data';
import 'package:fedcaretex_ai/core/network/api_client.dart';
import 'package:fedcaretex_ai/features/fl_engine/serialize.dart';
import 'package:fedcaretex_ai/features/fl_engine/identity.dart';

class FlSyncService {
  final ApiClient _api;

  FlSyncService({ApiClient? api}) : _api = api ?? apiClient;

  /// Mengambil model global (terbaru) dari server (beserta round_id)
  Future<Map<String, dynamic>> fetchGlobalModel() async {
    final response = await _api.get('/fl/global-model');
    // response: { round_id: int, hash: "hex", ledger_verified: bool, training: {...}, dp: {...} }
    return response;
  }

  /// Menjalankan keseluruhan pipeline upload:
  /// 1. Hash & Serialisasi Params (FLM1 kanonikal)
  /// 2. Signature dengan Ed25519
  /// 3. Upload HTTP POST ke `/fl/submit-update`
  Future<Map<String, dynamic>> submitUpdate({
    required int roundId,
    required Float32List localWeights,
    required Identity identity,
    required int numExamples,
  }) async {
    // 1. Serialization kanonikal (FLM1 header)
    final payloadBytes = CanonicalSerialize.toCanonicalBytes(localWeights);
    final payloadB64 = base64Encode(payloadBytes);
    
    // 2. Hashing (SHA-256)
    final updateHash = CanonicalSerialize.sha256Hex(payloadBytes);
    
    // 3. Tanda tangan (Ed25519)
    final signature = await identity.sign(roundId, updateHash);
    
    // 4. Kirim ke Backend Gateway
    final response = await _api.post('/fl/submit-update', body: {
      'client_id': identity.clientId,
      'round_id': roundId,
      'num_examples': numExamples,
      'payload_b64': payloadB64,
      'hash': updateHash,
      'signature': signature,
    });
    
    return response;
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }
}

final flSyncService = FlSyncService();
