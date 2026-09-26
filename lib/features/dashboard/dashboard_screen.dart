/// ====================================================================
/// File: dashboard_screen.dart
/// --------------------------------------------------------------------
/// Dashboard - Halaman Utama SmartWealth AI
///
/// Desain: Komik-pastel berwarna, bento grid cards
/// Fitur: Header profil, kartu utama kalori, bento 4 grid,
///        medication reminder preview, tips harian
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── 1. Header ────────────────────────────────
              _buildHeader(isDark),
              const SizedBox(height: 24),

              // ── 2. Greeting Banner ───────────────────────
              _buildGreetingBanner(),
              const SizedBox(height: 20),

              // ── 3. Stats Row ─────────────────────────────
              _buildStatsRow(),
              const SizedBox(height: 20),

              // ── 4. Bento Grid ─────────────────────────────
              _buildBentoGrid(),
              const SizedBox(height: 20),

              // ── 5. Medication Reminder ────────────────────
              _buildSectionTitle('Pengingat Obat', Icons.medication_rounded,
                  AppColors.cardPink),
              const SizedBox(height: 12),
              _buildMedicationPreview(),
              const SizedBox(height: 20),

              // ── 6. Daily Tips ─────────────────────────────
              _buildSectionTitle(
                  'Tips Hari Ini', Icons.lightbulb_rounded, AppColors.cardYellow),
              const SizedBox(height: 12),
              _buildDailyTip(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 2.5,
                ),
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Pagi 👋',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rownok Alam',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _iconBtn(Icons.search_rounded),
            const SizedBox(width: 8),
            _iconBtn(Icons.notifications_none_rounded, badge: true),
          ],
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, {bool badge = false}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimaryLight),
          if (badge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Greeting Banner ─────────────────────────────────────────
  Widget _buildGreetingBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantau Kesehatanmu',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Risiko pradiabetes kamu\nhari ini dalam kondisi stabil.',
                  style: GoogleFonts.quicksand(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Lihat Prediksi AI →',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      _Stat('82', 'mg/dL', 'Glukosa', AppColors.cardMint, Icons.water_drop_rounded),
      _Stat('23.4', 'BMI', 'Berat Badan', AppColors.cardBlue, Icons.monitor_weight_rounded),
      _Stat('72', 'bpm', 'Detak Jantung', AppColors.cardPink, Icons.favorite_rounded),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: s == stats.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, size: 18, color: AppColors.textPrimaryLight.withValues(alpha: 0.6)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.value,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        s.unit,
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  s.label,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Bento Grid ──────────────────────────────────────────────
  Widget _buildBentoGrid() {
    return Row(
      children: [
        // Left column — large card
        Expanded(
          flex: 5,
          child: _BentoCard(
            title: 'Olahraga',
            desc: 'Tetap aktif,\ntetap sehat',
            color: AppColors.cardPeach,
            icon: Icons.directions_run_rounded,
            height: 200,
          ),
        ),
        const SizedBox(width: 12),
        // Right column — 2 small cards
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _BentoCard(
                title: 'Tidur',
                desc: '7.5 jam semalam',
                color: AppColors.cardIndigo,
                icon: Icons.bedtime_rounded,
                height: 94,
              ),
              const SizedBox(height: 12),
              _BentoCard(
                title: 'Kalori',
                desc: '1450 / 2000 kkal',
                color: AppColors.cardYellow,
                icon: Icons.restaurant_rounded,
                height: 94,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section Title ────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimaryLight),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const Spacer(),
        Text(
          'Lihat Semua →',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Medication Preview ────────────────────────────────────────
  Widget _buildMedicationPreview() {
    final meds = [
      _Med('Metformin 500mg', '08:00', true),
      _Med('Glipizide 5mg', '12:00', false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: meds.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: m.taken
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.cardPeach,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    m.taken
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: m.taken
                        ? AppColors.success
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.name,
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: m.taken
                          ? AppColors.textSecondaryLight
                          : AppColors.textPrimaryLight,
                      decoration: m.taken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: m.taken
                        ? AppColors.cardMint
                        : AppColors.cardPeach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m.taken ? 'Diminum' : m.time,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: m.taken
                          ? AppColors.success
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Daily Tip ────────────────────────────────────────────────
  Widget _buildDailyTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardYellow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Pradiabetes',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berjalan kaki 30 menit setelah makan dapat menurunkan kadar gula darah hingga 20%.',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────
class _BentoCard extends StatelessWidget {
  final String title;
  final String desc;
  final Color color;
  final IconData icon;
  final double height;

  const _BentoCard({
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 16, color: AppColors.textPrimaryLight),
              ),
            ],
          ),
          Text(
            desc,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final String value, unit, label;
  final Color color;
  final IconData icon;
  const _Stat(this.value, this.unit, this.label, this.color, this.icon);
}

class _Med {
  final String name, time;
  final bool taken;
  const _Med(this.name, this.time, this.taken);
}
