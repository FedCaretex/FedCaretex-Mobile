/// ====================================================================
/// File: prediction_screen.dart
/// --------------------------------------------------------------------
/// Prediction - Hasil Prediksi AI Pradiabetes
/// Desain: Pastel risk gauge, SHAP feature bars, riwayat prediksi
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const riskPercent = 0.32; // 32% risiko
    const riskLabel = 'Risiko Sedang';
    const riskColor = AppColors.warning;

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
              // Header
              Text(
                'Prediksi AI',
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Analisis risiko pradiabetes berbasis ML',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // ── Risk Gauge Card ──────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.analytics_rounded,
                              color: AppColors.warning, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hasil Prediksi Terbaru',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimaryLight)),
                            Text('Diperbarui hari ini, 09:41',
                                style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Big percent display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '32',
                          style: GoogleFonts.inter(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '%',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        riskLabel,
                        style: GoogleFonts.quicksand(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: riskPercent,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(riskColor),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0% Aman',
                            style: GoogleFonts.quicksand(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold)),
                        Text('50% Sedang',
                            style: GoogleFonts.quicksand(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold)),
                        Text('100% Tinggi',
                            style: GoogleFonts.quicksand(
                                fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── SHAP Feature Importance ──────────────────
              Text(
                'Faktor Penentu (SHAP)',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fitur yang paling memengaruhi hasil prediksi',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              _buildSHAPCard(),
              const SizedBox(height: 24),

              // ── Input Data ──────────────────────────────
              Text(
                'Data Input Model',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputGrid(),
              const SizedBox(height: 24),

              // ── Recommendation ──────────────────────────
              _buildRecommendation(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSHAPCard() {
    final features = [
      _SHAP('Glukosa Puasa', 0.85, AppColors.error),
      _SHAP('BMI', 0.62, AppColors.warning),
      _SHAP('Usia', 0.55, AppColors.warning),
      _SHAP('Tekanan Darah', 0.38, AppColors.info),
      _SHAP('Aktivitas Fisik', 0.28, AppColors.success),
      _SHAP('Riwayat Keluarga', 0.20, AppColors.info),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: features.map((f) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    f.label,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: f.value,
                          backgroundColor:
                              f.color.withValues(alpha: 0.1),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(f.color),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(f.value * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: f.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputGrid() {
    final inputs = [
      _Input('Glukosa Puasa', '110 mg/dL', AppColors.cardMint),
      _Input('BMI', '23.4', AppColors.cardBlue),
      _Input('Tekanan Darah', '120/80', AppColors.cardPink),
      _Input('Usia', '34 tahun', AppColors.cardPeach),
      _Input('Aktivitas', '3x/minggu', AppColors.cardIndigo),
      _Input('Kolesterol', '180 mg/dL', AppColors.cardYellow),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: inputs.map((inp) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: inp.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(inp.label,
                  style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight)),
              Text(inp.value,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                'Rekomendasi Dokter AI',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Kurangi konsumsi karbohidrat sederhana',
            'Tingkatkan aktivitas fisik jadi 5x/minggu',
            'Pantau glukosa darah setiap pagi',
            'Konsultasikan dengan dokter dalam 2 minggu',
          ].map((tip) => Padding(
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
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SHAP {
  final String label;
  final double value;
  final Color color;
  const _SHAP(this.label, this.value, this.color);
}

class _Input {
  final String label, value;
  final Color color;
  const _Input(this.label, this.value, this.color);
}
