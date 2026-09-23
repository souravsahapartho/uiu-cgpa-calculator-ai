import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class GPAProgressRing extends StatefulWidget {
  final double currentGPA;
  final double maxGPA;
  final double? targetGPA;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final String label;

  const GPAProgressRing({
    super.key,
    required this.currentGPA,
    this.maxGPA = 4.00,
    this.targetGPA,
    this.size = 140,
    this.strokeWidth = 12,
    this.progressColor,
    this.label = 'CGPA',
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
    _animation = Tween<double>(begin: 0.0, end: widget.currentGPA).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GPAProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentGPA != widget.currentGPA) {
      _animation = Tween<double>(
        begin: oldWidget.currentGPA,
        end: widget.currentGPA,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedVal = _animation.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GPARingPainter(
                  currentGPA: animatedVal,
                  maxGPA: widget.maxGPA,
                  targetGPA: widget.targetGPA,
                  strokeWidth: widget.strokeWidth,
                  color: widget.progressColor ?? AppColors.primary,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedVal.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: widget.size * 0.24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'out of ${widget.maxGPA.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: widget.size * 0.09,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
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

class _GPARingPainter extends CustomPainter {
  final double currentGPA;
  final double maxGPA;
  final double? targetGPA;
  final double strokeWidth;
  final Color color;

  _GPARingPainter({
    required this.currentGPA,
    required this.maxGPA,
    this.targetGPA,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = AppColors.border.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = (currentGPA / maxGPA).clamp(0.0, 1.0) * 2 * math.pi;

    // Progress Arc Paint
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: (3 * math.pi) / 2,
        colors: [
          color.withOpacity(0.8),
          color,
          AppColors.primaryDark,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw active arc starting from 12 o'clock (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw Target Indicator if provided
    if (targetGPA != null && targetGPA! > 0) {
      final targetAngle = -math.pi / 2 + (targetGPA! / maxGPA).clamp(0.0, 1.0) * 2 * math.pi;
      final targetPoint = Offset(
        center.dx + radius * math.cos(targetAngle),
        center.dy + radius * math.sin(targetAngle),
      );

      final targetPaint = Paint()
        ..color = AppColors.navy
        ..style = PaintingStyle.fill;

      canvas.drawCircle(targetPoint, strokeWidth * 0.45, targetPaint);

      final targetInnerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(targetPoint, strokeWidth * 0.22, targetInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GPARingPainter oldDelegate) {
    return oldDelegate.currentGPA != currentGPA ||
        oldDelegate.targetGPA != targetGPA ||
        oldDelegate.color != color;
  }
}

