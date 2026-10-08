import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/uiu_notice_service.dart';
import '../models/uiu_notice.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'subtle_background.dart';

class UIUNoticeModal extends StatefulWidget {
  const UIUNoticeModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UIUNoticeModal(),
    );
  }

  @override
  State<UIUNoticeModal> createState() => _UIUNoticeModalState();
}

class _UIUNoticeModalState extends State<UIUNoticeModal> {
  final UIUNoticeService _service = UIUNoticeService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
    // Refresh to get fresh notices if available
    _service.fetchLatestNotices();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _openNoticeUrl(UIUNotice notice) async {
    await _service.markAsRead(notice.id);
    if (notice.link.isNotEmpty) {
      final uri = Uri.parse(notice.link);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: ${notice.link}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;

    final notices = _service.notices;
    final unreadCount = _service.unreadCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'UIU Official Notices',
                            style: AppTypography.titleMedium.copyWith(
                              color: textPri,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Text(
                                '$unreadCount New',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live announcements from uiu.ac.bd/notice',
                        style: AppTypography.bodySmall.copyWith(
                          color: textSec,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mark all read button
                if (unreadCount > 0)
                  TextButton.icon(
                    onPressed: () => _service.markAllAsRead(),
                    icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Mark Read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: textSec, size: 22),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderClr),

          // Content body
          Expanded(
            child: _service.isLoading && notices.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                        SizedBox(height: 12),
                        Text(
                          'Fetching official notices from UIU...',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : notices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mark_email_read_rounded, size: 48, color: textSec.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No notices found',
                                style: AppTypography.titleSmall.copyWith(color: textPri, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _service.errorMessage ?? 'Please check your internet connection and try refreshing.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(color: textSec),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () => _service.fetchLatestNotices(),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => _service.fetchLatestNotices(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: notices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notice = notices[index];
                            return _buildNoticeCard(
                              notice: notice,
                              isDark: isDark,
                              surface: surface,
                              borderClr: borderClr,
                              textPri: textPri,
                              textSec: textSec,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard({
    required UIUNotice notice,
    required bool isDark,
    required Color surface,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    final isUnread = !notice.isRead;

    return Container(
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF7ED))
            : surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.45)
              : borderClr,
          width: isUnread ? 1.4 : 1.0,
        ),
        boxShadow: isUnread ? AppShadows.soft : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderLg,
          onTap: () => _openNoticeUrl(notice),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUnread) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(
                          color: textPri,
                          fontSize: 13,
                          fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 10, color: textSec),
                          const SizedBox(width: 4),
                          Text(
                            notice.pubDate,
                            style: TextStyle(
                              color: textSec,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (notice.description.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    notice.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSec,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to open official notice',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

