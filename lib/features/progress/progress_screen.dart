/// ====================================================================
/// File: progress_screen.dart
/// --------------------------------------------------------------------
/// Progress - Grafik Kesehatan & Perkembangan Pasien
/// Desain: Pastel cards, timeline perkembangan, grafik
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  Text(
                    'Perkembangan',
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  _PillChip(label: 'Minggu Ini', active: true),
                  const SizedBox(width: 8),
                  _PillChip(label: 'Bulan', active: false),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pantau kondisi tubuh & risiko pradiabetes',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // ── Glucose Chart Card ──────────────────────
              _buildChartCard(
                title: 'Glukosa Darah',
                subtitle: 'mg/dL, 7 hari terakhir',
                color: AppColors.cardMint,
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.success,
                chartData: [82, 95, 88, 110, 92, 86, 90],
                maxVal: 140,
                unit: 'mg/dL',
              ),
              const SizedBox(height: 16),

              // ── Heart Rate Card ──────────────────────────
              _buildChartCard(
                title: 'Detak Jantung',
                subtitle: 'bpm, 7 hari terakhir',
                color: AppColors.cardPink,
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                chartData: [72, 68, 75, 80, 70, 74, 72],
                maxVal: 120,
                unit: 'bpm',
              ),
              const SizedBox(height: 16),

              // ── BMI Progress ─────────────────────────────
              _buildBMICard(),
              const SizedBox(height: 16),

              // ── Summary Timeline ─────────────────────────
              Text(
                'Riwayat Aktivitas',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildTimeline(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required List<int> chartData,
    required int maxVal,
    required String unit,
  }) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxData = chartData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimaryLight)),
                  Text(subtitle,
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight)),
                ],
              ),
              const Spacer(),
              Text(
                '${chartData.last}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                ' $unit',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(chartData.length, (i) {
                final barHeight = (chartData[i] / maxData) * 60;
                final isLast = i == chartData.length - 1;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400 + i * 60),
                      width: 28,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isLast
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[i],
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        color: isLast
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                        fontWeight:
                            isLast ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    const bmi = 23.4;
    const progress = 0.62; // 23.4 / 37.5 (max)

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.monitor_weight_rounded,
                    color: AppColors.info, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Indeks Massa Tubuh (BMI)',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$bmi',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Normal',
                    style: GoogleFonts.quicksand(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.info),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kurus 18.5',
                  style: GoogleFonts.quicksand(
                      fontSize: 10, color: AppColors.textSecondaryLight)),
              Text('Normal 25',
                  style: GoogleFonts.quicksand(
                      fontSize: 10,
                      color: AppColors.info,
                      fontWeight: FontWeight.bold)),
              Text('Gemuk 30+',
                  style: GoogleFonts.quicksand(
                      fontSize: 10, color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final items = [
      _TimelineItem('Glukosa Normal', '90 mg/dL', '09:00', AppColors.success, Icons.water_drop_rounded),
      _TimelineItem('Berjalan 30 Menit', '2.500 langkah', '07:30', AppColors.info, Icons.directions_walk_rounded),
      _TimelineItem('Obat Diminum', 'Metformin 500mg', '08:00', AppColors.warning, Icons.medication_rounded),
    ];

    return Column(
      children: items.asMap().entries.map((e) {
        final item = e.value;
        final isLast = e.key == items.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 18, color: item.color),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimaryLight)),
                          Text(item.subtitle,
                              style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    Text(item.time,
                        style: GoogleFonts.quicksand(
                            fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final bool active;
  const _PillChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
            : [],
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _TimelineItem {
  final String title, subtitle, time;
  final Color color;
  final IconData icon;
  const _TimelineItem(this.title, this.subtitle, this.time, this.color, this.icon);
}
