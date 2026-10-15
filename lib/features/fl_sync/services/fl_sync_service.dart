import 'dart:convert';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../fl_engine/data.dart';
import '../../fl_engine/dp.dart';
import '../../fl_engine/identity.dart';
import '../../fl_engine/model.dart';
import '../../fl_engine/serialize.dart';

/// Pelanggaran integritas (hash tidak cocok, ledger belum memverifikasi, dst).
class FlIntegrityException implements Exception {
  final String message;
  FlIntegrityException(this.message);

  @override
  String toString() => message;
}

/// Satu catatan lokal berlabel (label = hasil diabetes terkonfirmasi, 0/1).
class LabeledRecord {
  final ClinicalInput input;
  final int label;
  const LabeledRecord(this.input, this.label);

  Map<String, dynamic> toJson() => {'input': input.toJson(), 'label': label};

  factory LabeledRecord.fromJson(Map<String, dynamic> json) => LabeledRecord(
        ClinicalInput.fromJson(json['input'] as Map<String, dynamic>),
        (json['label'] as num).toInt(),
      );
}

/// Model global yang SUDAH diverifikasi (hash cocok + tercatat di ledger).
class GlobalModel {
  final int roundId; // ronde yang harus dilatih klien
  final int modelVersion;
  final String hash;
  final Float32List params;
  final Float32List shapBaseline;
  final String algo;
  final double proxMu;
  final int localEpochs;
  final double lr;
  final int batchSize;
  final bool dpEnabled;
  final double clipNorm;
  final double noiseMultiplier;
  final double? epsilonPerRound;
  final double riskLow;
  final double riskHigh;
  final String dataSource;

  const GlobalModel({
    required this.roundId,
    required this.modelVersion,
    required this.hash,
    required this.params,
    required this.shapBaseline,
    required this.algo,
    required this.proxMu,
    required this.localEpochs,
    required this.lr,
    required this.batchSize,
    required this.dpEnabled,
    required this.clipNorm,
    required this.noiseMultiplier,
    required this.epsilonPerRound,
    required this.riskLow,
    required this.riskHigh,
    required this.dataSource,
  });
}

/// Hasil satu ronde pengiriman update.
class SyncReport {
  final String clientId;
  final int roundId;
  final int modelVersion;
  final String updateHash;
  final int numExamples;
  final int pendingInRound;
  final int minClients;
  final bool aggregated;
  final double? clientEpsilon;
  final bool auditVerified;
  final String dataSource;

  const SyncReport({
    required this.clientId,
    required this.roundId,
    required this.modelVersion,
    required this.updateHash,
    required this.numExamples,
    required this.pendingInRound,
    required this.minClients,
    required this.aggregated,
    required this.clientEpsilon,
    required this.auditVerified,
    required this.dataSource,
  });
}

/// Klien protokol FL (meniru `flsys/client.py` di backend):
/// daftar -> unduh & verifikasi model -> latih lokal -> delta -> DP ->
/// serialisasi FLM1 -> SHA-256 -> tanda tangan Ed25519 -> kirim -> cek audit.
class FlSyncService {
  FlSyncService({ApiClient? api}) : _api = api ?? apiClient;

  final ApiClient _api;

  /// Mengunduh model global dan MEMVERIFIKASI: SHA-256(byte) == hash,
  /// ledger_verified == true, jumlah parameter benar. Gagal -> FlIntegrityException.
  Future<GlobalModel> fetchVerifiedModel() async {
    final j = await _api.get('/fl/global-model') as Map<String, dynamic>;

    final Uint8List raw = base64Decode(j['params_b64'] as String);
    final claimed = (j['hash'] as String).toLowerCase();
    if (CanonicalSerialize.sha256Hex(raw) != claimed) {
      throw FlIntegrityException(
          'Hash model global tidak cocok dengan byte yang diterima.');
    }
    if (j['ledger_verified'] != true) {
      throw FlIntegrityException(
          'Hash model global belum terverifikasi di ledger.');
    }

    final params = CanonicalSerialize.fromCanonicalBytes(raw);
    if (params.length != MLPModel.totalParams) {
      throw FlIntegrityException(
          'Jumlah parameter ${params.length} != ${MLPModel.totalParams}.');
    }

    final baseline = Float32List.fromList([
      for (final e in (j['shap_baseline'] as List)) (e as num).toDouble()
    ]);
    if (baseline.length != ClinicalData.nEncoded) {
      throw FlIntegrityException(
          'Baseline SHAP harus ${ClinicalData.nEncoded} kolom.');
    }

    final training = j['training'] as Map<String, dynamic>;
    final dp = j['dp'] as Map<String, dynamic>;
    final risk = j['risk_thresholds'] as Map<String, dynamic>?;

    return GlobalModel(
      roundId: (j['round_id'] as num).toInt(),
      modelVersion: (j['model_version'] as num).toInt(),
      hash: claimed,
      params: params,
      shapBaseline: baseline,
      algo: training['algo'] as String,
      proxMu: (training['prox_mu'] as num).toDouble(),
      localEpochs: (training['local_epochs'] as num).toInt(),
      lr: (training['lr'] as num).toDouble(),
      batchSize: (training['batch_size'] as num).toInt(),
      dpEnabled: dp['enabled'] as bool,
      clipNorm: (dp['clip_norm'] as num).toDouble(),
      noiseMultiplier: (dp['noise_multiplier'] as num).toDouble(),
      epsilonPerRound: (dp['epsilon_per_round'] as num?)?.toDouble(),
      // Backend lama belum mengirim ambang -> pakai default backend.
      riskLow: (risk?['low'] as num?)?.toDouble() ?? 0.3,
      riskHigh: (risk?['high'] as num?)?.toDouble() ?? 0.6,
      dataSource: j['data_source'] as String? ?? '',
    );
  }

  /// Mendaftarkan public key; client_id dari server harus = SHA-256(pk) lokal.
  Future<String> register(Identity identity) async {
    final r = await _api.post('/fl/register-client',
        body: {'public_key': identity.publicKeyHex});
    final cid = r['client_id'] as String;
    if (cid != identity.clientId) {
      throw FlIntegrityException(
          'client_id dari server tidak sama dengan SHA-256(public key) lokal.');
    }
    return cid;
  }

  /// Menjalankan satu ronde lengkap. [onStatus] dipanggil di tiap tahap.
  Future<SyncReport> runRound({
    required Identity identity,
    required List<LabeledRecord> records,
    void Function(String status)? onStatus,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('Belum ada data lokal untuk dilatih.');
    }

    Future<void> step(String s) async {
      onStatus?.call(s);
      // beri kesempatan UI repaint sebelum pekerjaan CPU berikutnya
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }

    await step('Mendaftarkan identitas perangkat...');
    final clientId = await register(identity);

    await step('Mengunduh & memverifikasi model global...');
    final gm = await fetchVerifiedModel();

    await step('Melatih model di perangkat (${records.length} catatan)...');
    final x = [for (final r in records) ClinicalData.encode(r.input)];
    final y = [for (final r in records) r.label.toDouble()];
    final local = MLPModel.trainLocal(
      wGlobal: gm.params,
      X: x,
      y: y,
      epochs: gm.localEpochs,
      lr: gm.lr,
      batchSize: gm.batchSize,
      proxMu: gm.algo == 'fedprox' ? gm.proxMu : 0.0,
    );

    await step('Menerapkan privasi diferensial & menandatangani...');
    var delta = Float32List(local.length);
    for (var i = 0; i < local.length; i++) {
      delta[i] = local[i] - gm.params[i];
    }
    if (gm.dpEnabled) {
      delta = DP.applyDP(delta, gm.clipNorm, gm.noiseMultiplier);
    }
    final payload = CanonicalSerialize.toCanonicalBytes(delta);
    final hash = CanonicalSerialize.sha256Hex(payload);
    final signature = await identity.sign(gm.roundId, hash);

    await step('Mengirim pembaruan model (bukan data kesehatan)...');
    final r = await _api.post('/fl/submit-update', body: {
      'client_id': clientId,
      'round_id': gm.roundId,
      'num_examples': records.length,
      'payload_b64': base64Encode(payload),
      'hash': hash,
      'signature': signature,
    });

    await step('Memeriksa jejak audit di ledger...');
    var audited = false;
    try {
      final a = await _api.get(
              '/audit/verify?round_id=${gm.roundId}&hash=$hash&client_id=$clientId')
          as Map<String, dynamic>;
      audited = a['verified'] == true;
    } catch (_) {
      // pemeriksaan tambahan; kegagalannya tidak membatalkan update yang sudah diterima
    }

    return SyncReport(
      clientId: clientId,
      roundId: gm.roundId,
      modelVersion: gm.modelVersion,
      updateHash: hash,
      numExamples: records.length,
      pendingInRound: (r['pending_in_round'] as num).toInt(),
      minClients: (r['min_clients'] as num).toInt(),
      aggregated: r['aggregated'] == true,
      clientEpsilon: (r['client_epsilon'] as num?)?.toDouble(),
      auditVerified: audited,
      dataSource: gm.dataSource,
    );
  }

  /// [DEMO] Paksa agregasi walau update < FL_MIN_CLIENTS.
  Future<Map<String, dynamic>> aggregateNow() => _api.post('/fl/aggregate');

  /// [DEMO] 1 pasien acak dari dataset server (`/dataset/random`) + label asli.
  /// Hanya untuk mengisi data lokal saat demo; BUKAN data pasien nyata.
  Future<LabeledRecord> fetchDemoRecord() async {
    final j = await _api.get('/dataset/random') as Map<String, dynamic>;
    return LabeledRecord(
      ClinicalInput.fromJson(j),
      (j['diabetes_actual'] as num).toInt(),
    );
  }
}
