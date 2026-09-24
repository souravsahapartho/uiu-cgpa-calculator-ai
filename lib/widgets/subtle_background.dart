import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubtleBackground extends StatelessWidget {
  final Widget child;

  const SubtleBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base subtle background pattern
        Positioned.fill(
          child: Container(
            color: AppColors.scaffold,
          ),
        ),
        // Soft glowing circular element 1 (Primary Deep Blue glow)
        Positioned(
          top: -120,
          right: -100,
          child: IgnorePointer(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Soft glowing element 2 (Accent Amber warmth)
        Positioned(
          bottom: -100,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.05),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Central subtle geometric water-ring
        Positioned(
          top: 250,
          left: -140,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.03),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        // Foreground Content
        child,
      ],
    );
  }
}
