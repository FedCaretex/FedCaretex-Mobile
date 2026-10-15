import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/prediction_models.dart';
import '../../shared/widgets/fade_in.dart';
import '../fl_engine/data.dart';
import '../fl_sync/services/fl_sync_provider.dart';
import 'components/shap_bar_chart.dart';
import 'services/prediction_provider.dart';

class PredictionScreen extends ConsumerStatefulWidget {
  const PredictionScreen({super.key});

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  final _c = {
    'age': TextEditingController(text: '45'),
    'bmi': TextEditingController(text: '25'),
    'hba1c': TextEditingController(text: '5.5'),
    'glucose': TextEditingController(text: '100'),
  };
  String _gender = 'Female';
  String _smoking = 'never';
  bool _hypertension = false;
  bool _heartDisease = false;
  bool _filling = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(String key) =>
      double.tryParse(_c[key]!.text.trim().replaceAll(',', '.'));

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    // Rentang sama dengan validasi pydantic di backend (schemas.ClinicalFeatures).
    final errs = <String>[];
    double? read(String key, String label, double lo, double hi) {
      final v = _num(key);
      if (v == null || v < lo || v > hi) {
        errs.add('$label (${lo.toInt()}-${hi.toInt()})');
        return null;
      }
      return v;
    }

    final age = read('age', 'Usia', 0, 120);
    final bmi = read('bmi', 'BMI', 10, 100);
    final hba1c = read('hba1c', 'HbA1c', 3, 20);
    final glucose = read('glucose', 'Glukosa', 40, 500);
    if (errs.isNotEmpty) {
      _toast('Periksa isian: ${errs.join(', ')}');
      return;
    }

    final input = ClinicalInput(
      gender: _gender,
      age: age!,
      hypertension: _hypertension ? 1 : 0,
      heartDisease: _heartDisease ? 1 : 0,
      smokingHistory: _smoking,
      bmi: bmi!,
      hba1c: hba1c!,
      bloodGlucose: glucose!,
    );
    await ref.read(predictionProvider.notifier).predict(input);
  }

  /// [DEMO] Isi form dengan 1 pasien acak dari dataset server.
  Future<void> _fillDemo() async {
    setState(() => _filling = true);
    try {
      final rec = await ref.read(flSyncServiceProvider).fetchDemoRecord();
      final i = rec.input;
      if (!mounted) return;
      setState(() {
        _c['age']!.text = i.age.toString();
        _c['bmi']!.text = i.bmi.toString();
        _c['hba1c']!.text = i.hba1c.toString();
        _c['glucose']!.text = i.bloodGlucose.toString();
        _gender = i.gender;
        _smoking = i.smokingHistory;
        _hypertension = i.hypertension == 1;
        _heartDisease = i.heartDisease == 1;
      });
    } catch (e) {
      if (mounted) _toast(describeFlError(e));
    } finally {
      if (mounted) setState(() => _filling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);
    final result = state.result;
    final history = state.allHistory;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInUp(
                child: Text(
                  'Prediksi risiko',
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  'Isi data kesehatanmu. Hasil dilengkapi penjelasan faktor, bukan hanya angka.',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _InputCard(
                  controllers: _c,
                  gender: _gender,
                  smoking: _smoking,
                  hypertension: _hypertension,
                  heartDisease: _heartDisease,
                  onDevice: state.onDevice,
                  loading: state.loading,
                  filling: _filling,
                  onGender: (v) => setState(() => _gender = v),
                  onSmoking: (v) => setState(() => _smoking = v),
                  onHypertension: (v) => setState(() => _hypertension = v),
                  onHeartDisease: (v) => setState(() => _heartDisease = v),
                  onOnDevice: (v) =>
                      ref.read(predictionProvider.notifier).setOnDevice(v),
                  onFillDemo: _fillDemo,
                  onSubmit: _submit,
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!,
                    style: GoogleFonts.quicksand(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ],
              if (result != null) ...[
                const SizedBox(height: 20),
                FadeScaleIn(child: _RiskCard(result: result)),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  child: ShapBarChart(items: result.shapBreakdown),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  child: _RecommendationCard(items: result.recommendations),
                ),
              ],
              if (history.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Riwayat prediksi',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                ...history.take(5).map((h) => _HistoryTile(item: h)),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _dec(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );

class _InputCard extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final String gender;
  final String smoking;
  final bool hypertension;
  final bool heartDisease;
  final bool onDevice;
  final bool loading;
  final bool filling;
  final ValueChanged<String> onGender;
  final ValueChanged<String> onSmoking;
  final ValueChanged<bool> onHypertension;
  final ValueChanged<bool> onHeartDisease;
  final ValueChanged<bool> onOnDevice;
  final VoidCallback onFillDemo;
  final VoidCallback onSubmit;

  const _InputCard({
    required this.controllers,
    required this.gender,
    required this.smoking,
    required this.hypertension,
    required this.heartDisease,
    required this.onDevice,
    required this.loading,
    required this.filling,
    required this.onGender,
    required this.onSmoking,
    required this.onHypertension,
    required this.onHeartDisease,
    required this.onOnDevice,
    required this.onFillDemo,
    required this.onSubmit,
  });

  static const genderLabels = {
    'Female': 'Perempuan',
    'Male': 'Laki-laki',
    'Other': 'Lainnya',
  };
  static const smokingLabels = {
    'No Info': 'Tidak ada info',
    'never': 'Tidak pernah',
    'former': 'Mantan perokok',
    'current': 'Perokok aktif',
    'not current': 'Bukan perokok saat ini',
    'ever': 'Pernah merokok',
  };

  Widget _numField(String key, String label, double width) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _dec(label),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    Map<String, String> labels,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _dec(label),
      items: [
        for (final o in options)
          DropdownMenuItem(
            value: o,
            child: Text(labels[o] ?? o, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: onDevice,
            onChanged: loading ? null : onOnDevice,
            title: Text('Hitung di perangkat',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
            subtitle: Text(
              onDevice
                  ? 'Data klinis tidak dikirim ke server.'
                  : 'Data dikirim ke server untuk dihitung.',
              style: GoogleFonts.quicksand(
                  fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              // Lebar dihitung dari kartu sebenarnya (sudah dikurangi padding).
              final w = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _numField('age', 'Usia (tahun)', w),
                  _numField('bmi', 'BMI', w),
                  _numField('hba1c', 'HbA1c (%)', w),
                  _numField('glucose', 'Glukosa (mg/dL)', w),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          _dropdown('Jenis kelamin', gender, ClinicalData.genderCats,
              genderLabels, onGender),
          const SizedBox(height: 10),
          _dropdown('Riwayat merokok', smoking, ClinicalData.smokingCats,
              smokingLabels, onSmoking),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: hypertension,
            onChanged: onHypertension,
            title: Text('Hipertensi', style: GoogleFonts.quicksand()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: heartDisease,
            onChanged: onHeartDisease,
            title: Text('Penyakit jantung', style: GoogleFonts.quicksand()),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Lihat hasil & penjelasan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: (loading || filling) ? null : onFillDemo,
              child: Text(
                filling ? 'Mengambil data contoh...' : 'Isi dengan data contoh (demo)',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final PredictionResult result;
  const _RiskCard({required this.result});

  Color get _color {
    switch (result.category) {
      case 'Rendah':
        return AppColors.success;
      case 'Tinggi':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text('Skor risiko',
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: result.riskScore),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                value.toStringAsFixed(0),
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Risiko ${result.category.toLowerCase()}',
              style: GoogleFonts.quicksand(
                  color: _color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result.source == 'device' ? 'Dihitung di perangkat' : 'Dihitung di server'}'
            ' · model v${result.modelVersion}',
            style: GoogleFonts.quicksand(
                fontSize: 11, color: AppColors.textSecondaryLight),
          ),
          if (result.dataSource == 'synthetic')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Model dilatih dengan data sintetis (hanya untuk demo).',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final List<String> items;
  const _RecommendationCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saran praktis',
              style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 10),
          ...items.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.quicksand(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risiko ${item.category}',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                Text(
                  'Faktor utama: ${item.topFeature}',
                  style: GoogleFonts.quicksand(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Text('${item.riskScore.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
