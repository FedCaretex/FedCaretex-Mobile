import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/utils/quick_settings_sheet.dart';
import '../../shared/widgets/fade_in.dart';
import '../auth/auth_provider.dart';
import '../main_screen.dart';
import 'components/bento_square_card.dart';
import 'components/global_search_sheet.dart';
import 'components/notification_center_sheet.dart';
import 'components/profile_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final name = session?.name ?? 'Rownok';

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
              const SizedBox(height: 16),
              FadeInUp(
                child: ProfileHeader(
                  userName: name,
                  photoUrl: session?.photoUrl,
                  onAvatarTap: () => QuickSettingsSheet.show(context),
                  onSearchTap: () => GlobalSearchSheet.show(context),
                  onNotificationTap: () =>
                      NotificationCenterSheet.show(context),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: _TodaySummaryCard(
                  onSeeProgress: () =>
                      ref.read(bottomNavIndexProvider.notifier).setIndex(1),
                ),
              ),
              const SizedBox(height: 16),
              FadeScaleIn(
                delay: const Duration(milliseconds: 140),
                child: _ProgressHero(
                  onCheck: () =>
                      ref.read(bottomNavIndexProvider.notifier).setIndex(4),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: BentoSquareCard(
                        title: 'Olahraga',
                        description: 'Tetap aktif,\ntetap sehat',
                        backgroundColor: AppColors.cardPeach,
                        icon: Icons.directions_run_rounded,
                        onTap: () => ref
                            .read(bottomNavIndexProvider.notifier)
                            .setIndex(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoSquareCard(
                        title: 'Jantung',
                        description: 'Nikmati hidup\nsepenuhnya',
                        backgroundColor: AppColors.cardIndigo,
                        icon: Icons.favorite_rounded,
                        onTap: () => ref
                            .read(bottomNavIndexProvider.notifier)
                            .setIndex(1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 260),
                child: Row(
                  children: [
                    Expanded(
                      child: BentoSquareCard(
                        title: 'Tidur',
                        description: 'Cek kualitas\ntidurmu',
                        backgroundColor: AppColors.cardMint,
                        icon: Icons.bedtime_rounded,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoSquareCard(
                        title: 'BMI',
                        description: 'Kendalikan\nberat badan',
                        backgroundColor: AppColors.cardCoral,
                        icon: Icons.monitor_weight_rounded,
                        onTap: () => ref
                            .read(bottomNavIndexProvider.notifier)
                            .setIndex(1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 320),
                child: _buildSectionTitle('Pengingat obat hari ini'),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 360),
                child: _MedicationPreview(
                  onOpen: () =>
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final VoidCallback onSeeProgress;
  const _TodaySummaryCard({required this.onSeeProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardRed,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ringkasan hari ini',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '110 mg/dL',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Macro(label: 'Glukosa', value: '110'),
              _Macro(label: 'BMI', value: '23.4'),
              _Macro(label: 'Jantung', value: '72'),
              _Macro(label: 'Risiko', value: '32%'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Hari ini',
                style: GoogleFonts.quicksand(
                    fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeProgress,
                child: Text(
                  'Lihat perkembangan',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final String value;
  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.quicksand(
                fontSize: 11, color: AppColors.textSecondaryLight)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight)),
      ],
    );
  }
}

class _ProgressHero extends StatelessWidget {
  final VoidCallback onCheck;
  const _ProgressHero({required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardIndigo,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progres sehatmu',
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  'Kebiasaan hari ini sudah bagus. Cek prediksi risiko untuk penjelasan lengkap.',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onCheck,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Cek prediksi',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: _RingPainter(0.78, AppColors.primary),
              child: Center(
                child: Text(
                  '78%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      6.28 * value,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}

class _MedicationPreview extends StatelessWidget {
  final VoidCallback onOpen;
  const _MedicationPreview({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardPink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.medication_rounded, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Metformin 500mg',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('2 dari 4 sudah diminum',
                      style: GoogleFonts.quicksand(
                          fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
