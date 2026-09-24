import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/semester_transcript.dart';

class GPATrendLineChart extends StatelessWidget {
  final List<SemesterTranscript> semesters;
  final double height;

  const GPATrendLineChart({
    super.key,
    required this.semesters,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (semesters.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text('No semester data available'),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _GPATrendPainter(semesters: semesters),
      ),
    );
  }
}

class _GPATrendPainter extends CustomPainter {
  final List<SemesterTranscript> semesters;

  _GPATrendPainter({required this.semesters});

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingLeft = 32.0;
    final double paddingBottom = 28.0;
    final double paddingTop = 16.0;
    final double paddingRight = 16.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final minGPA = 2.50;
    final maxGPA = 4.00;

    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Horizontal Grid Lines (2.5, 3.0, 3.5, 4.0)
    final gridValues = [2.5, 3.0, 3.5, 4.0];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var gpa in gridValues) {
      final y = paddingTop + chartHeight - ((gpa - minGPA) / (maxGPA - minGPA)) * chartHeight;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: gpa.toStringAsFixed(1),
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    if (semesters.isEmpty) return;

    final points = <Offset>[];
    final cgpaPoints = <Offset>[];
    final stepX = chartWidth / (semesters.length > 1 ? (semesters.length - 1) : 1);

    for (int i = 0; i < semesters.length; i++) {
      final x = paddingLeft + (semesters.length > 1 ? i * stepX : chartWidth / 2);
      final sgpa = semesters[i].sgpa.clamp(minGPA, maxGPA);
      final cgpa = semesters[i].cgpa.clamp(minGPA, maxGPA);

      final ySgpa = paddingTop + chartHeight - ((sgpa - minGPA) / (maxGPA - minGPA)) * chartHeight;
      final yCgpa = paddingTop + chartHeight - ((cgpa - minGPA) / (maxGPA - minGPA)) * chartHeight;

      points.add(Offset(x, ySgpa));
      cgpaPoints.add(Offset(x, yCgpa));

      // Draw X-axis label (T1, T2, etc.)
      textPainter.text = TextSpan(
        text: 'T${semesters[i].semesterIndex}',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 20));
    }

    // Draw Gradient Area under CGPA line
    if (cgpaPoints.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(cgpaPoints.first.dx, size.height - paddingBottom);
      for (var pt in cgpaPoints) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(cgpaPoints.last.dx, size.height - paddingBottom);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.primary.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw SGPA Line (Dashed / Soft Navy)
    final sgpaLinePaint = Paint()
      ..color = AppColors.navy.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], sgpaLinePaint);
    }

    // Draw CGPA Line (Bold UIU Orange)
    final cgpaLinePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(cgpaPoints.first.dx, cgpaPoints.first.dy);
    for (int i = 1; i < cgpaPoints.length; i++) {
      linePath.lineTo(cgpaPoints[i].dx, cgpaPoints[i].dy);
    }
    canvas.drawPath(linePath, cgpaLinePaint);

    // Draw Data Point Circles
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var pt in cgpaPoints) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 2.5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GPATrendPainter oldDelegate) => true;
}

class GradeDistributionBarChart extends StatelessWidget {
  final Map<String, int> gradeDistribution;
  final double height;

  const GradeDistributionBarChart({
    super.key,
    required this.gradeDistribution,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (gradeDistribution.isEmpty) return const SizedBox.shrink();

    final maxCount = gradeDistribution.values.fold(0, (max, count) => count > max ? count : max);
    final effectiveMax = maxCount == 0 ? 1 : maxCount;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: gradeDistribution.entries.map((entry) {
          final count = entry.value;
          final ratio = count / effectiveMax;
          final isHighGrade = entry.key.startsWith('A') || entry.key.startsWith('B+');

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: count > 0 ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: (height - 60) * math.max(ratio, 0.06),
                    decoration: BoxDecoration(
                      gradient: isHighGrade
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [
                                AppColors.navy.withOpacity(0.3),
                                AppColors.navy.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isHighGrade ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

