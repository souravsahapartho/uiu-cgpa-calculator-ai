import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../screens/profile_screen.dart';

class UIUHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showProfileButton;

  const UIUHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
    this.onBack,
    this.showProfileButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBack) ...[
                  IconButton(
                    onPressed: onBack ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing!,
              if (showProfileButton) ...[
                if (trailing != null) const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  borderRadius: AppRadius.borderFull,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

