/// ====================================================================
/// File: shap_bar_chart.dart
/// --------------------------------------------------------------------
/// SHAP Feature Importance Bar Chart — Pure Flutter (no fl_chart)
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ShapBarChart extends StatelessWidget {
  const ShapBarChart({super.key});

  static const _features = [
    _ShapFeature('Glukosa Puasa', 0.85, AppColors.error),
    _ShapFeature('BMI', 0.62, AppColors.warning),
    _ShapFeature('Usia', 0.55, Color(0xFF6C63FF)),
    _ShapFeature('Tekanan Darah', 0.38, AppColors.info),
    _ShapFeature('Aktivitas Fisik', 0.28, AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
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
            'Feature Importance (SHAP)',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 20),
          // Bar chart rows
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildBarRow(f),
              )),
        ],
      ),
    );
  }

  Widget _buildBarRow(_ShapFeature f) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            f.label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 12,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: f.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      height: 12,
                      width: constraints.maxWidth * f.value,
                      decoration: BoxDecoration(
                        color: f.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 3),
              Text(
                '${(f.value * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: f.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShapFeature {
  final String label;
  final double value;
  final Color color;
  const _ShapFeature(this.label, this.value, this.color);
}
