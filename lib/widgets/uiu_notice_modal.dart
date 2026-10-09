import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/uiu_notice_service.dart';
import '../models/uiu_notice.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

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

          // Dynamic & Responsive Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'UIU Notices',
                              style: AppTypography.titleMedium.copyWith(
                                color: textPri,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Text(
                                '$unreadCount New',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: const Text(
                                'All read',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        'Latest Notices',
                        style: AppTypography.bodySmall.copyWith(
                          color: textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Mark all read button
                if (unreadCount > 0)
                  InkWell(
                    onTap: () => _service.markAllAsRead(),
                    borderRadius: AppRadius.borderFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderFull,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.done_all_rounded, size: 12, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text(
                            'Mark read',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: textSec, size: 21),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
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
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          itemCount: notices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 7),
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
    final topic = _getNoticeTopic(notice.title, notice.description);
    final formattedTitle = _formatNoticeTitle(notice.title);
    final coreReason = _extractCoreReason(notice.description, notice.title);

    return Container(
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF7ED))
            : surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.45)
              : borderClr,
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: isUnread ? AppShadows.soft : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: () => _openNoticeUrl(notice),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top meta bar: Topic badge, unread dot, and date
                Row(
                  children: [
                    if (isUnread) ...[
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    // Topic category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: topic.color.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(topic.icon, size: 10, color: topic.color),
                          const SizedBox(width: 3.5),
                          Text(
                            topic.label,
                            style: TextStyle(
                              color: topic.color,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 9.5, color: textSec.withValues(alpha: 0.7)),
                        const SizedBox(width: 3.5),
                        Text(
                          notice.pubDate,
                          style: TextStyle(
                            color: textSec.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Main Title (Clean formatted title, Max 2 lines, bold)
                Text(
                  formattedTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPri,
                    fontSize: 12.5,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                // Core Reason / Topic Details (Max 3 lines, direct reason)
                if (coreReason.isNotEmpty) ...[
                  const SizedBox(height: 3.5),
                  Text(
                    coreReason,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSec,
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatNoticeTitle(String title) {
    var clean = title.trim();
    // Strip redundant leading prefixes like "NOTICE REGARDING", "NOTICE FOR", "NOTICE:"
    clean = clean.replaceAll(RegExp(r'^(URGENT\s+)?NOTICE(\s+REGARDING|\s+FOR|\s+ON)?[\s:–—\-]+', caseSensitive: false), '');
    // If title is ALL CAPS, convert to clean Title Case
    if (clean.length > 4 && clean == clean.toUpperCase()) {
      clean = clean.split(' ').map((word) {
        if (word.isEmpty) return word;
        // Keep roman numerals or short acronyms intact (e.g., UIU, BSCSE, CSE, II, III)
        if (word.length <= 3 || RegExp(r'^(UIU|CSE|EEE|BBA|FYDP|GPA|CGPA|COVID|SMS|OTP)$').hasMatch(word)) {
          return word;
        }
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }
    return clean.isEmpty ? title : clean;
  }

  static _NoticeTopic _getNoticeTopic(String title, String desc) {
    final text = ('$title $desc').toLowerCase();
    if (text.contains('transport') ||
        text.contains('bus') ||
        text.contains('shuttle') ||
        text.contains('route') ||
        text.contains('driver') ||
        text.contains('pickup') ||
        text.contains('drop-off')) {
      return const _NoticeTopic('Transport', Icons.directions_bus_rounded, Color(0xFF0284C7));
    } else if (text.contains('exam') || text.contains('mid term') || text.contains('final') || text.contains('routine')) {
      return const _NoticeTopic('Exam Schedule', Icons.event_note_rounded, Color(0xFFEF4444));
    } else if (text.contains('withdrawal') || text.contains('withdraw')) {
      return const _NoticeTopic('Course Withdrawal', Icons.warning_amber_rounded, Color(0xFFF59E0B));
    } else if (text.contains('class') || text.contains('makeup') || text.contains('schedule') || text.contains('academic calendar')) {
      return const _NoticeTopic('Schedule Update', Icons.calendar_month_rounded, Color(0xFF0EA5E9));
    } else if (text.contains('library') || text.contains('study room') || text.contains('campus')) {
      return const _NoticeTopic('Campus Facility', Icons.local_library_rounded, Color(0xFF10B981));
    } else if (text.contains('waiver') || text.contains('scholarship') || text.contains('fee') || text.contains('tuition')) {
      return const _NoticeTopic('Waiver & Fees', Icons.monetization_on_rounded, Color(0xFFEAB308));
    } else if (text.contains('holiday') || text.contains('vacation') || text.contains('closed')) {
      return const _NoticeTopic('Holiday', Icons.beach_access_rounded, Color(0xFF8B5CF6));
    } else if (text.contains('admission') || text.contains('orientation')) {
      return const _NoticeTopic('Admission', Icons.school_rounded, Color(0xFF6366F1));
    }
    return const _NoticeTopic('UIU Official', Icons.campaign_rounded, AppColors.primary);
  }

  static String _extractCoreReason(String desc, String title) {
    if (desc.isEmpty) return '';
    var clean = desc
        .replaceAll(RegExp(r'#\s*Program\s*School\s*List[\s\S]*?(?=\b(?:due to|this is|all students|please|effective)\b|$)', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(Attention|ATTENTION|Notice|NOTICE)[\s\w,:\-]*?(All Students|Employees|Concerned)[\s\w,:\-]*?:', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(Attention\s+All\s+Students\s+and\s+Employees\s+of\s+UIU)[\s,:]*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(This is to inform all concerned that|This is to inform that|It is hereby notified that|This is for the information of all students that)[\s,]*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(All students are hereby informed that)[\s,]*', caseSensitive: false), '')
        .replaceAll(RegExp(r'#+\s*'), '')
        .trim();

    if (clean.isNotEmpty) {
      clean = clean[0].toUpperCase() + clean.substring(1);
    }

    if (clean.toLowerCase() == title.toLowerCase() || clean.isEmpty) {
      return '';
    }
    return clean;
  }
}

class _NoticeTopic {
  final String label;
  final IconData icon;
  final Color color;

  const _NoticeTopic(this.label, this.icon, this.color);
}

