/// ====================================================================
/// File: shap_bar_chart.dart
/// SHAP feature contribution — bar horizontal dengan animasi lebar.
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/prediction_models.dart';

class ShapBarChart extends StatelessWidget {
  final List<ShapItem> items;

  const ShapBarChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxAbs = items
        .map((e) => e.contribution.abs())
        .reduce((a, b) => a > b ? a : b)
        .clamp(0.0001, 999);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kenapa hasilnya seperti ini',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semakin panjang batang, semakin besar pengaruhnya pada skor.',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 18),
          ...items.take(6).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            final ratio = (f.contribution.abs() / maxAbs).clamp(0.08, 1.0);
            final color = f.contribution >= 0 ? AppColors.warning : AppColors.success;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.label,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Text(
                        f.contribution >= 0 ? 'menaikkan' : 'menurunkan',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: Duration(milliseconds: 500 + i * 90),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LayoutBuilder(builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 12,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Container(
                              height: 12,
                              width: constraints.maxWidth * value,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    f.explanation,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
