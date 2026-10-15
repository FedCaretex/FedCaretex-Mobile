import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../fl_engine/identity.dart';
import 'fl_sync_service.dart';
import 'local_data_store.dart';

final flSyncServiceProvider = Provider<FlSyncService>((ref) => FlSyncService());
final localDataStoreProvider = Provider<LocalDataStore>((ref) => LocalDataStore());

/// Minimal catatan lokal sebelum boleh melatih (hindari update dari data terlalu sedikit).
const int kMinLocalRecords = 20;

String describeFlError(Object e) {
  if (e is ApiException || e is FlIntegrityException) return e.toString();
  if (e is ArgumentError || e is RangeError || e is FormatException) {
    return 'Kesalahan pemrosesan di perangkat: $e';
  }
  return 'Tidak bisa menghubungi server. Pastikan backend berjalan dan alamatnya benar.';
}

class FlSyncState {
  final bool busy;
  final String status;
  final List<LabeledRecord> records;
  final GlobalModel? model;
  final SyncReport? report;
  final String? error;

  const FlSyncState({
    this.busy = false,
    this.status = '',
    this.records = const [],
    this.model,
    this.report,
    this.error,
  });

  FlSyncState copyWith({
    bool? busy,
    String? status,
    List<LabeledRecord>? records,
    GlobalModel? model,
    SyncReport? report,
    String? error,
    bool clearError = false,
    bool clearReport = false,
  }) {
    return FlSyncState(
      busy: busy ?? this.busy,
      status: status ?? this.status,
      records: records ?? this.records,
      model: model ?? this.model,
      report: clearReport ? null : (report ?? this.report),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FlSyncNotifier extends StateNotifier<FlSyncState> {
  FlSyncNotifier(this._service, this._store) : super(const FlSyncState()) {
    _init();
  }

  final FlSyncService _service;
  final LocalDataStore _store;
  Identity? _identity;

  Future<void> _init() async {
    final records = await _store.load();
    if (!mounted) return;
    state = state.copyWith(records: records);
  }

  /// Mengunduh & memverifikasi model global untuk ditampilkan.
  Future<void> refreshModel() async {
    state = state.copyWith(busy: true, status: 'Memeriksa model global...', clearError: true);
    try {
      final gm = await _service.fetchVerifiedModel();
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', model: gm);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', error: describeFlError(e));
    }
  }

  /// [DEMO] Ambil [count] pasien acak dari server sebagai data lokal simulasi.
  Future<void> loadDemoData({int count = 50}) async {
    state = state.copyWith(busy: true, clearError: true);
    final records = [...state.records];
    try {
      for (var i = 0; i < count; i++) {
        if (!mounted) return;
        state = state.copyWith(status: 'Mengambil data contoh ${i + 1}/$count...');
        records.add(await _service.fetchDemoRecord());
      }
      await _store.save(records);
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', records: records);
    } catch (e) {
      // simpan yang sudah terambil agar tidak mengulang dari nol
      if (records.length > state.records.length) await _store.save(records);
      if (!mounted) return;
      state = state.copyWith(
        busy: false,
        status: '',
        records: records,
        error: describeFlError(e),
      );
    }
  }

  Future<void> clearData() async {
    await _store.clear();
    if (!mounted) return;
    state = state.copyWith(records: const [], clearReport: true, clearError: true);
  }

  Future<void> runSync() async {
    if (state.records.length < kMinLocalRecords) {
      state = state.copyWith(
        error: 'Butuh minimal $kMinLocalRecords catatan lokal (saat ini ${state.records.length}).',
      );
      return;
    }
    state = state.copyWith(busy: true, status: 'Menyiapkan...', clearError: true, clearReport: true);
    try {
      _identity ??= await Identity.loadOrCreate();
      final report = await _service.runRound(
        identity: _identity!,
        records: state.records,
        onStatus: (s) {
          if (mounted) state = state.copyWith(status: s);
        },
      );
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', report: report);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', error: describeFlError(e));
    }
  }

  /// [DEMO] Paksa agregasi saat update < FL_MIN_CLIENTS.
  Future<void> aggregateNow() async {
    state = state.copyWith(busy: true, status: 'Meminta server melakukan agregasi...', clearError: true);
    try {
      await _service.aggregateNow();
      final gm = await _service.fetchVerifiedModel();
      if (!mounted) return;
      final prev = state.report;
      state = state.copyWith(
        busy: false,
        status: '',
        model: gm,
        report: prev == null
            ? null
            : SyncReport(
                clientId: prev.clientId,
                roundId: prev.roundId,
                modelVersion: gm.modelVersion,
                updateHash: prev.updateHash,
                numExamples: prev.numExamples,
                pendingInRound: 0,
                minClients: prev.minClients,
                aggregated: true,
                clientEpsilon: prev.clientEpsilon,
                auditVerified: prev.auditVerified,
                dataSource: prev.dataSource,
              ),
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false, status: '', error: describeFlError(e));
    }
  }
}

final flSyncProvider = StateNotifierProvider<FlSyncNotifier, FlSyncState>((ref) {
  return FlSyncNotifier(
    ref.watch(flSyncServiceProvider),
    ref.watch(localDataStoreProvider),
  );
});
