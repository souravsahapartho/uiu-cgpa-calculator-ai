import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/semester_transcript.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';

class GPATrendLineChart extends StatelessWidget {
  final List<SemesterTranscript> semesters;
  final double height;

  const GPATrendLineChart({
    super.key,
    required this.semesters,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (semesters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.soft,
      ),
      child: CustomPaint(
        size: Size(double.infinity, height - 32),
        painter: _LineChartPainter(semesters: semesters),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<SemesterTranscript> semesters;

  _LineChartPainter({required this.semesters});

  @override
  void paint(Canvas canvas, Size size) {
    if (semesters.length < 2) return;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // 4 Horizontal Grid Lines (4.0, 3.0, 2.0, 1.0)
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double stepX = size.width / (semesters.length - 1);
    const double minGPA = 2.0;
    const double maxGPA = 4.0;

    final points = <Offset>[];
    for (int i = 0; i < semesters.length; i++) {
      final gpa = semesters[i].cgpa.clamp(minGPA, maxGPA);
      final normalizedY = 1.0 - ((gpa - minGPA) / (maxGPA - minGPA));
      final x = i * stepX;
      final y = normalizedY * (size.height - 16) + 8;
      points.add(Offset(x, y));
    }

    // Fill Gradient Path
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line Path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Point Markers
    final pointPaint = Paint()..color = AppColors.primary;
    final pointInner = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 5, pointPaint);
      canvas.drawCircle(p, 2.5, pointInner);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

class GradeDistributionChart extends StatelessWidget {
  final Map<String, int> distribution;
  final double height;

  const GradeDistributionChart({
    super.key,
    required this.distribution,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution.values.isEmpty ? 1 : distribution.values.reduce(math.max);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: distribution.entries.map((entry) {
          final barHeight = maxCount > 0 ? (entry.value / maxCount) * (height - 65) : 0.0;
          final isTopGrade = entry.key.startsWith('A');

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${entry.value}',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 22,
                height: math.max(6.0, barHeight),
                decoration: BoxDecoration(
                  color: isTopGrade ? AppColors.primary : AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.key,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: isTopGrade ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
