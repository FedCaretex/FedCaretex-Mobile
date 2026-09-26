/// ====================================================================
/// File: base_screen.dart
/// --------------------------------------------------------------------
/// Widget BaseScreen - Wrapper layar umum SmartWealth AI
///
/// Terinspirasi dari Synexa BaseScreen — menyederhanakan
/// pembuatan setiap halaman agar konsisten.
///
/// Fitur:
/// - SafeArea opsional
/// - AppBar opsional
/// - Warna background dari AppColors
/// - Padding horizontal default
/// - extendBodyBehindAppBar support
/// ====================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BaseScreen extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? drawer;
  final Widget body;
  final bool resizeToAvoidBottomInset;
  final double? horizontalPadding;
  final bool useSafeArea;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;

  const BaseScreen({
    super.key,
    this.appBar,
    this.backgroundColor,
    this.drawer,
    required this.body,
    this.resizeToAvoidBottomInset = false,
    this.horizontalPadding,
    this.useSafeArea = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      body: useSafeArea
          ? SafeArea(child: _buildBody(context))
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0),
        child: body,
      ),
    );
  }
}
