/// ====================================================================
/// File: fl_sync_screen.dart
/// --------------------------------------------------------------------
/// Federated Learning Hub - Sinkronisasi Model AI
/// Desain: Gradient card, animasi loading, log aktivitas pastel
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

// ── State ────────────────────────────────────────────────────
class _SyncNotifier extends StateNotifier<bool> {
  _SyncNotifier() : super(false);
  void setStatus(bool v) => state = v;
}

final isSyncingProvider = StateNotifierProvider<_SyncNotifier, bool>(
  (ref) => _SyncNotifier(),
);


// ── Screen ───────────────────────────────────────────────────
class FlSyncScreen extends ConsumerWidget {
  const FlSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(isSyncingProvider);

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
                'Federated Learning',
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Kontribusi ke model AI global tanpa berbagi data',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // ── Privacy Shield Card ──────────────────────
              Container(
                padding: const EdgeInsets.all(22),
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
                child: Column(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Data Kamu 100% Aman',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data medis mentah tidak pernah meninggalkan perangkat ini. Hanya bobot model terenkripsi yang dikirim ke server global.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSyncing)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            isSyncing
                                ? 'Melatih model lokal...'
                                : 'Model sudah terkini ✓',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSyncing
                            ? null
                            : () async {
                                ref
                                    .read(isSyncingProvider.notifier)
                                    .setStatus(true);
                                await Future.delayed(
                                    const Duration(seconds: 4));
                                ref
                                    .read(isSyncingProvider.notifier)
                                    .setStatus(false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isSyncing ? 'Sedang Sync...' : 'Mulai Sync Aman',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Info Cards Row ───────────────────────────
              Row(
                children: [
                  _buildInfoCard('Model Round', '47', AppColors.cardIndigo,
                      Icons.loop_rounded),
                  const SizedBox(width: 12),
                  _buildInfoCard('Akurasi', '89.3%', AppColors.cardMint,
                      Icons.bar_chart_rounded),
                  const SizedBox(width: 12),
                  _buildInfoCard('Kontribusi', '12x', AppColors.cardPeach,
                      Icons.volunteer_activism_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // ── Network Logs ─────────────────────────────
              Row(
                children: [
                  const Icon(Icons.history_rounded,
                      color: AppColors.textPrimaryLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log Aktivitas Jaringan',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
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
                  children: [
                    _buildLogItem('Bobot global diunduh', '09:40', Colors.green),
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    _buildLogItem('Epoch lokal selesai (5/5)', '09:35', Colors.blue),
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    _buildLogItem('Differential Privacy diterapkan', '09:34', Colors.purple),
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    _buildLogItem('Gradien terenkripsi dikirim', '09:34', Colors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimaryLight.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String title, String time, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.check_circle_rounded, size: 16, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        Text(
          time,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
