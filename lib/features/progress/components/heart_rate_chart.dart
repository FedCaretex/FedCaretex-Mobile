/// ====================================================================
/// File: heart_rate_chart.dart
/// --------------------------------------------------------------------
/// Heart Rate Chart — Pure Flutter CustomPainter (no fl_chart)
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class HeartRateChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;

  const HeartRateChart({
    super.key,
    this.dataPoints = const [80.0, 75.0, 110.0, 85.0, 90.0, 78.0, 92.0],
    this.labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  });

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.error, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detak Jantung',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'bpm, 7 hari terakhir',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _LineChartPainter(
                dataPoints: dataPoints,
                lineColor: AppColors.error,
                fillColor: AppColors.error.withValues(alpha: 0.08),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(
                      l,
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        color: AppColors.textSecondaryLight,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter ────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b) - 10;
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b) + 10;
    final range = maxVal - minVal;

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i / (dataPoints.length - 1) * size.width;
      final y = size.height - ((dataPoints[i] - minVal) / range * size.height);
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = fillColor,
    );

    // Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    // Bezier curve for smooth line
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(linePath, linePaint);

    // Dots on each point
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 5, dotBg);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints;
}
