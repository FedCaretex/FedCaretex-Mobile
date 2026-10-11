import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/prediction_models.dart';
import '../../shared/widgets/fade_in.dart';
import 'components/shap_bar_chart.dart';
import 'services/prediction_provider.dart';

class PredictionScreen extends ConsumerStatefulWidget {
  const PredictionScreen({super.key});

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  final _form = {
    'pregnancies': TextEditingController(text: '1'),
    'glucose': TextEditingController(text: '110'),
    'blood_pressure': TextEditingController(text: '80'),
    'skin_thickness': TextEditingController(text: '22'),
    'insulin': TextEditingController(text: '85'),
    'bmi': TextEditingController(text: '23.4'),
    'diabetes_pedigree': TextEditingController(text: '0.35'),
    'age': TextEditingController(text: '34'),
  };

  @override
  void dispose() {
    for (final c in _form.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final features = <String, dynamic>{
      'pregnancies': double.parse(_form['pregnancies']!.text),
      'glucose': double.parse(_form['glucose']!.text),
      'blood_pressure': double.parse(_form['blood_pressure']!.text),
      'skin_thickness': double.parse(_form['skin_thickness']!.text),
      'insulin': double.parse(_form['insulin']!.text),
      'bmi': double.parse(_form['bmi']!.text),
      'diabetes_pedigree': double.parse(_form['diabetes_pedigree']!.text),
      'age': int.parse(_form['age']!.text),
    };
    await ref.read(predictionProvider.notifier).predict(features);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionProvider);
    final result = state.result;

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
                child: _InputCard(form: _form, onSubmit: _submit, loading: state.loading),
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
              if (state.history.isNotEmpty) ...[
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
                ...state.history.take(5).map((h) => _HistoryTile(item: h)),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Map<String, TextEditingController> form;
  final VoidCallback onSubmit;
  final bool loading;

  const _InputCard({
    required this.form,
    required this.onSubmit,
    required this.loading,
  });

  static const labels = {
    'pregnancies': 'Kehamilan',
    'glucose': 'Glukosa',
    'blood_pressure': 'Tekanan darah',
    'skin_thickness': 'Lipatan kulit',
    'insulin': 'Insulin',
    'bmi': 'BMI',
    'diabetes_pedigree': 'Riwayat keluarga',
    'age': 'Usia',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: form.entries.map((e) {
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 72) / 2,
                child: TextField(
                  controller: e.value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: labels[e.key],
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
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
