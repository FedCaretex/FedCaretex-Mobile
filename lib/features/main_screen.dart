/// ====================================================================
/// File: main_screen.dart
/// --------------------------------------------------------------------
/// MainScreen - Hub navigasi utama SmartWealth AI
///
/// Menggunakan AppNavbar (terinspirasi Synexa CustomNavbar)
/// dengan AnimatedSwitcher untuk perpindahan layar smooth.
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard/dashboard_screen.dart';
import 'medication/medication_screen.dart';
import 'progress/progress_screen.dart';
import 'prediction/prediction_screen.dart';
import 'fl_sync/fl_sync_screen.dart';
import '../core/widgets/app_navbar.dart';

// ── Provider ────────────────────────────────────────────────
class _NavNotifier extends StateNotifier<int> {
  _NavNotifier() : super(0);
  void setIndex(int i) => state = i;
}

final bottomNavIndexProvider = StateNotifierProvider<_NavNotifier, int>(
  (ref) => _NavNotifier(),
);

// ── MainScreen ──────────────────────────────────────────────
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const _screens = [
    DashboardScreen(),
    ProgressScreen(),
    MedicationScreen(),
    FlSyncScreen(),
    PredictionScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      extendBody: true,
      // ── Page Body with smooth fade+slide transition ──
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: _screens[currentIndex],
        ),
      ),
      // ── Floating Pill Navbar ─────────────────────────
      bottomNavigationBar: AppNavbar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).setIndex(i),
      ),
    );
  }
}
