import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/prediction_models.dart';
import '../../auth/auth_provider.dart';

class PredictionState {
  final bool loading;
  final PredictionResult? result;
  final List<HistoryItem> history;
  final String? error;

  const PredictionState({
    this.loading = false,
    this.result,
    this.history = const [],
    this.error,
  });

  PredictionState copyWith({
    bool? loading,
    PredictionResult? result,
    List<HistoryItem>? history,
    String? error,
  }) {
    return PredictionState(
      loading: loading ?? this.loading,
      result: result ?? this.result,
      history: history ?? this.history,
      error: error,
    );
  }
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  PredictionNotifier(this.ref) : super(const PredictionState());

  final Ref ref;

  Future<void> predict(Map<String, dynamic> features) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final userId = ref.read(authProvider)?.userId ?? 'demo-user';
      final json = await apiClient.post('/predict', body: {
        ...features,
        'user_id': userId,
      });
      final result =
          PredictionResult.fromJson(json as Map<String, dynamic>);
      await loadHistory();
      state = state.copyWith(loading: false, result: result);
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Server prediksi belum siap. Pastikan backend berjalan.',
      );
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
