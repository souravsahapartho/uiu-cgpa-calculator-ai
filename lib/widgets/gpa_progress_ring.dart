import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

class GPAProgressRing extends StatefulWidget {
  final double currentGPA;
  final double maxGPA;
  final double? targetGPA;
  final double size;
  final String label;

  const GPAProgressRing({
    super.key,
    required this.currentGPA,
    this.maxGPA = 4.0,
    this.targetGPA,
    this.size = 190,
    this.label = 'Current CGPA',
  });

  @override
  State<GPAProgressRing> createState() => _GPAProgressRingState();
}

class _GPAProgressRingState extends State<GPAProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final targetPercent = (widget.currentGPA / widget.maxGPA).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: 0.0, end: targetPercent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GPAProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentGPA != widget.currentGPA) {
      final targetPercent = (widget.currentGPA / widget.maxGPA).clamp(0.0, 1.0);
      _animation = Tween<double>(
        begin: _animation.value,
        end: targetPercent,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForGPA(double gpa) {
    if (gpa >= 3.67) return AppColors.success;
    if (gpa >= 3.00) return AppColors.primary;
    if (gpa >= 2.50) return AppColors.accent;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = _getColorForGPA(widget.currentGPA);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedGPA = _animation.value * widget.maxGPA;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painted Dual Ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  targetProgress: widget.targetGPA != null
                      ? (widget.targetGPA! / widget.maxGPA).clamp(0.0, 1.0)
                      : null,
                  ringColor: ringColor,
                  backgroundColor: AppColors.border,
                ),
              ),
              // Center GPA Value and Labels
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    animatedGPA.toStringAsFixed(2),
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ringColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      'Out of ${widget.maxGPA.toStringAsFixed(2)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: ringColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double? targetProgress;
  final Color ringColor;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    this.targetProgress,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Target marker if present
    if (targetProgress != null) {
      final targetAngle = -math.pi / 2 + (targetProgress! * 2 * math.pi);
      final targetPaint = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill;

      final markerX = center.dx + radius * math.cos(targetAngle);
      final markerY = center.dy + radius * math.sin(targetAngle);
      canvas.drawCircle(Offset(markerX, markerY), 7, targetPaint);
    }

    // Active progress arc with gradient
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [ringColor.withValues(alpha: 0.8), ringColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.targetProgress != targetProgress ||
        oldDelegate.ringColor != ringColor;
  }
}
