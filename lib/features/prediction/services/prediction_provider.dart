import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/prediction_models.dart';
import '../../auth/auth_provider.dart';
import '../../fl_engine/data.dart';
import '../../fl_sync/services/fl_sync_provider.dart';
import 'on_device_predictor.dart';

class PredictionState {
  final bool loading;
  final PredictionResult? result;
  final List<HistoryItem> history; // riwayat di server (/history/{user_id})
  final List<HistoryItem> localHistory; // hasil on-device (hanya di memori)
  final String? error;
  final bool onDevice;

  const PredictionState({
    this.loading = false,
    this.result,
    this.history = const [],
    this.localHistory = const [],
    this.error,
    this.onDevice = true,
  });

  /// Gabungan riwayat server + on-device, terbaru di atas.
  List<HistoryItem> get allHistory {
    final all = [...localHistory, ...history];
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  PredictionState copyWith({
    bool? loading,
    PredictionResult? result,
    List<HistoryItem>? history,
    List<HistoryItem>? localHistory,
    String? error,
    bool clearError = false,
    bool? onDevice,
  }) {
    return PredictionState(
      loading: loading ?? this.loading,
      result: result ?? this.result,
      history: history ?? this.history,
      localHistory: localHistory ?? this.localHistory,
      error: clearError ? null : (error ?? this.error),
      onDevice: onDevice ?? this.onDevice,
    );
  }
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  PredictionNotifier(this.ref) : super(const PredictionState());

  final Ref ref;

  void setOnDevice(bool value) {
    state = state.copyWith(onDevice: value, clearError: true);
  }

  Future<void> predict(ClinicalInput input) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      if (state.onDevice) {
        // Unduh + verifikasi model global terbaru, hitung SEMUA di perangkat.
        final gm = await ref.read(flSyncServiceProvider).fetchVerifiedModel();
        final result = OnDevicePredictor.predict(gm, input);
        final now = DateTime.now();
        final item = HistoryItem(
          id: now.microsecondsSinceEpoch.toString(),
          category: result.category,
          riskScore: result.riskScore,
          topFeature: result.shapBreakdown.first.label,
          timestamp: now,
        );
        state = state.copyWith(
          loading: false,
          result: result,
          localHistory: [item, ...state.localHistory],
        );
      } else {
        final userId = ref.read(authProvider)?.userId ?? 'demo-user';
        final json = await apiClient.post('/predict', body: {
          ...input.toJson(),
          'user_id': userId,
        });
        final result = PredictionResult.fromJson(json);
        state = state.copyWith(loading: false, result: result);
        await loadHistory();
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: describeFlError(e));
    }
  }

  Future<void> loadHistory() async {
    try {
      final userId = ref.read(authProvider)?.userId ?? 'demo-user';
      final json = await apiClient.get('/history/$userId');
      final items = (json as List)
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(history: items);
    } catch (_) {}
  }
}

final predictionProvider =
    StateNotifierProvider<PredictionNotifier, PredictionState>(
  (ref) => PredictionNotifier(ref),
);
