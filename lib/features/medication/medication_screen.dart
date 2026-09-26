/// ====================================================================
/// File: medication_screen.dart
/// --------------------------------------------------------------------
/// Medication Logger - Pencatatan & Pengingat Obat
/// Desain: Date strip carousel, checklist card pastel
/// Terinspirasi dari Synexa MedicationChecklistCard
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

// ── Model ─────────────────────────────────────────────────────
class MedItem {
  final String id, name, dose, time;
  final bool isTaken;
  const MedItem(
      {required this.id,
      required this.name,
      required this.dose,
      required this.time,
      this.isTaken = false});
  MedItem copyWith({bool? isTaken}) =>
      MedItem(id: id, name: name, dose: dose, time: time, isTaken: isTaken ?? this.isTaken);
}

// ── Provider ──────────────────────────────────────────────────
class _MedNotifier extends StateNotifier<List<MedItem>> {
  _MedNotifier() : super([
    const MedItem(id: '1', name: 'Metformin', dose: '500 mg', time: '08:00', isTaken: true),
    const MedItem(id: '2', name: 'Glipizide', dose: '5 mg', time: '12:00'),
    const MedItem(id: '3', name: 'Atorvastatin', dose: '10 mg', time: '21:00'),
    const MedItem(id: '4', name: 'Vitamin D3', dose: '1000 IU', time: '08:00', isTaken: true),
  ]);

  void toggle(String id) {
    state = state
        .map((m) => m.id == id ? m.copyWith(isTaken: !m.isTaken) : m)
        .toList();
  }
}

final medicationProvider = StateNotifierProvider<_MedNotifier, List<MedItem>>(
  (ref) => _MedNotifier(),
);


// ── Screen ────────────────────────────────────────────────────
class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});
  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  int _selectedDayIndex = 3; // today = Thu

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _dates = [21, 22, 23, 24, 25, 26, 27];

  @override
  Widget build(BuildContext context) {
    final meds = ref.watch(medicationProvider);
    final taken = meds.where((m) => m.isTaken).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddMedSheet(context),
          elevation: 0,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Tambah Obat',
            style: GoogleFonts.quicksand(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Obat',
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress indicator
                  Row(
                    children: [
                      Text(
                        '$taken/${meds.length} obat sudah diminum',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: meds.isEmpty ? 0 : taken / meds.length,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Date Strip ──────────────────────────
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 7,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final isSelected = i == _selectedDayIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDayIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 52,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.primaryGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 6,
                                      )
                                    ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _days[i],
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_dates[i]}',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Med List ───────────────────────────────────
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                itemCount: meds.length,
                itemBuilder: (_, i) {
                  final med = meds[i];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _MedCard(
                      key: ValueKey('${med.id}_${med.isTaken}'),
                      med: med,
                      onToggle: () =>
                          ref.read(medicationProvider.notifier).toggle(med.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tambah Obat Baru',
              style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 16),
            Text('(Form akan ditambahkan di iterasi berikutnya)',
                style: GoogleFonts.quicksand(
                    color: AppColors.textSecondaryLight)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Med Card ─────────────────────────────────────────────────
class _MedCard extends StatelessWidget {
  final MedItem med;
  final VoidCallback onToggle;

  const _MedCard({super.key, required this.med, required this.onToggle});

  static const _colors = [
    AppColors.cardMint,
    AppColors.cardBlue,
    AppColors.cardPink,
    AppColors.cardIndigo,
    AppColors.cardPeach,
  ];

  @override
  Widget build(BuildContext context) {
    final colorIdx = med.id.hashCode % _colors.length;
    final cardColor = _colors[colorIdx];

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: med.isTaken ? Colors.white : cardColor,
          borderRadius: BorderRadius.circular(22),
          border: med.isTaken
              ? Border.all(
                  color: AppColors.success.withValues(alpha: 0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: med.isTaken
                    ? AppColors.success
                    : Colors.white.withValues(alpha: 0.7),
                border: Border.all(
                  color: med.isTaken
                      ? AppColors.success
                      : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: med.isTaken
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 14),
            // Med info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: med.isTaken
                          ? AppColors.textSecondaryLight
                          : AppColors.textPrimaryLight,
                      decoration:
                          med.isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.dose,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // Time & status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      med.time,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: med.isTaken
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    med.isTaken ? 'Diminum ✓' : 'Belum',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: med.isTaken
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
