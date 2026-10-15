/// ====================================================================
/// File: app_navbar.dart
/// --------------------------------------------------------------------
/// Widget AppNavbar - Navigasi Bawah FedCaretex AI
///
/// Terinspirasi dari Synexa CustomNavbar:
/// - Floating pill design dengan shadow
/// - Tab aktif menampilkan gradient Indigo
/// - HapticFeedback saat tap
/// - Responsif dark/light theme
/// - Animated container per tab
/// - Label muncul hanya saat tab aktif (pill expanding)
///
/// Author: FedCaretex Dev Team
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
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      gradient: AppColors.navHomeGradient,
      shadowColor: Color(0xFF4F46E5),
    ),
    _NavItem(
      icon: Icons.bar_chart_rounded,
      label: 'Progress',
      gradient: AppColors.navProgressGradient,
      shadowColor: Color(0xFF059669),
    ),
    _NavItem(
      icon: Icons.medication_rounded,
      label: 'Obat',
      gradient: AppColors.navMedicationGradient,
      shadowColor: Color(0xFFEA580C),
    ),
    _NavItem(
      icon: Icons.wifi_tethering_rounded,
      label: 'Sync',
      gradient: AppColors.navSyncGradient,
      shadowColor: Color(0xFF0284C7),
    ),
    _NavItem(
      icon: Icons.analytics_rounded,
      label: 'AI',
      gradient: AppColors.navAiGradient,
      shadowColor: Color(0xFF7C3AED),
    ),
  ];

  static const double _height = 64;
  static const double _maxWidth = 380;
  static const double _innerPad = 6;
  static const double _iconSize = 22;
  static const double _labelGap = 7;
  static const double _pillPadX = 14;
  static const double _minInactive = 40;

  static const Duration _dur = Duration(milliseconds: 580);
  static const Curve _curve = Curves.easeOutCubic;

  static final TextStyle _labelStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.bold,
    fontSize: 13,
    letterSpacing: 0.2,
  );

  static double _activeWidth(int index, double total) {
    final tp = TextPainter(
      text: TextSpan(text: _items[index].label, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelW = tp.width;
    tp.dispose();

    final wanted = _iconSize + _labelGap + labelW + _pillPadX * 2 + 2;
    final maxAllowed = total - (_items.length - 1) * _minInactive;
    return wanted > maxAllowed ? maxAllowed : wanted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxWidth),
        child: Container(
          height: _height,
          margin: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1D2E).withValues(alpha: 0.97)
                : Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: (currentIndex >= 0 && currentIndex < _items.length)
                    ? _items[currentIndex]
                        .shadowColor
                        .withValues(alpha: isDark ? 0.22 : 0.10)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final total = constraints.maxWidth - _innerPad * 2;
                final activeW = _activeWidth(currentIndex, total);
                final inactiveW = (total - activeW) / (_items.length - 1);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _innerPad),
                  child: Row(
                    children: List.generate(
                      _items.length,
                      (i) {
                        final active = currentIndex == i;
                        return AnimatedContainer(
                          duration: _dur,
                          curve: _curve,
                          width: active ? activeW : inactiveW,
                          height: _height,
                          child: _NavButton(
                            item: _items[i],
                            active: active,
                            isDark: isDark,
                            photoUrl: i == 4 ? photoUrl : null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onTap(i);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final bool isDark;
  final String? photoUrl;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.isDark,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        isDark ? AppColors.navbarIconInactive : const Color(0xFF8E95A9);
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder(
          tween: Tween<double>(end: active ? 1.0 : 0.0),
          duration: AppNavbar._dur,
          curve: AppNavbar._curve,
          builder: (context, t, _) {
            final iconColor = Color.lerp(inactiveColor, Colors.white, t)!;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Opacity(
                      opacity: t,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: item.gradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: item.shadowColor
                                  .withValues(alpha: isDark ? 0.45 : 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      hasPhoto
                          ? _Avatar(url: photoUrl!, fallbackColor: iconColor)
                          : Icon(item.icon,
                              size: AppNavbar._iconSize, color: iconColor),
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: t,
                          child: Opacity(
                            opacity: t * t,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppNavbar._labelGap),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                softWrap: false,
                                style: AppNavbar._labelStyle
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final Color fallbackColor;
  const _Avatar({required this.url, required this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person_rounded,
            size: 20,
            color: fallbackColor,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Color shadowColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.shadowColor,
  });
}
