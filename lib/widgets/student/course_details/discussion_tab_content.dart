import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../generated_l10n/app_localizations.dart';

class DiscussionTabContent extends StatelessWidget {
  final bool isDark;
  final int? courseId;

  const DiscussionTabContent({
    super.key,
    required this.isDark,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (courseId == null || courseId! <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE4E7EC),
          ),
        ),
        child: Text(
          l10n.studentDiscussionUnavailable,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF667085),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF16213E), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFEFF6FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFDBEAFE),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155CFB).withValues(alpha: isDark ? 0.14 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF50A2FF), Color(0xFF155CFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.forum_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.studentDiscussionTabTitle,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.studentDiscussionTabSubtitle,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              onPressed: () => context.push('/course/$courseId/discussions'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF155CFB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(l10n.studentDiscussionTabOpen),
            ),
          ),
        ],
      ),
    );
  }
}
