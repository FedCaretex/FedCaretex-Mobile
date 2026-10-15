/// ====================================================================
/// File: main_screen.dart
/// --------------------------------------------------------------------
/// MainScreen - Hub navigasi utama FedCaretex AI
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
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final PageController _pageController;

  static const _screens = [
    DashboardScreen(),
    ProgressScreen(),
    MedicationScreen(),
    FlSyncScreen(),
    PredictionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(bottomNavIndexProvider),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int targetIndex) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (currentIndex == targetIndex) return;

    ref.read(bottomNavIndexProvider.notifier).setIndex(targetIndex);

    final distance = (targetIndex - currentIndex).abs();

    final duration = Duration(milliseconds: 360 + (distance * 80));

    _pageController.animateToPage(
      targetIndex,
      duration: duration,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
