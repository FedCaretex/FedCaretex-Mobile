/// ====================================================================
/// File: app_navbar.dart
/// --------------------------------------------------------------------
/// Widget AppNavbar - Navigasi Bawah SmartWealth AI
///
/// Terinspirasi dari Synexa CustomNavbar:
/// - Floating pill design dengan shadow
/// - Tab aktif menampilkan gradient Indigo
/// - HapticFeedback saat tap
/// - Responsif dark/light theme
/// - Animated container per tab
/// - Label muncul hanya saat tab aktif (pill expanding)
///
/// Author: SmartWealth Dev Team
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? photoUrl;

  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.photoUrl,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItem(icon: Icons.medication_rounded, label: 'Obat'),
    _NavItem(icon: Icons.wifi_tethering_rounded, label: 'Sync'),
    _NavItem(icon: Icons.analytics_rounded, label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
      height: 68,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1D2E).withValues(alpha: 0.97)
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          _items.length,
          (i) => _buildItem(context, i, isDark),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, bool isDark) {
    final isActive = currentIndex == index;
    final item = _items[index];

    // Profile tab (index 4 = AI) — show special icon behavior
    if (index == 4 && photoUrl != null && photoUrl!.isNotEmpty) {
      return _buildProfileTab(index, isActive, isDark);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 16 : 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              color: isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? AppColors.navbarIconInactive
                          : const Color(0xFFBBC0D0)),
                ),
                // Label slides in/out
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: isActive ? null : 0,
                    child: isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Text(
                              item.label,
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(int index, bool isActive, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive ? AppColors.primaryGradient : null,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    size: 20,
                    color:
                        isActive ? Colors.white : AppColors.navbarIconInactive,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
