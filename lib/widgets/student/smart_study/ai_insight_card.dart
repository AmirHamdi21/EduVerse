import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../bloc/smart_study/smart_study_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight insight;
  final bool isDark;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onRefresh;

  const AiInsightCard({
    super.key,
    required this.insight,
    required this.isDark,
    this.onBookmarkToggle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E2939),
                  const Color(0xFF1E2939).withValues(alpha: 0.8),
                ]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2B7FFF).withValues(alpha: 0.3)
              : const Color(0xFF2B7FFF).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF2B7FFF,
            ).withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B7FFF).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.smartStudyAiInsight,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF101828),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getTimeAgo(),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF99A1AF)
                            : const Color(0xFF4A5565),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRefreshButton(context),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? const Color(0xFF364153) : const Color(0xFFBFDBFE))
                      .withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            insight.message,
            style: TextStyle(
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
              fontSize: 14,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 18),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.lightbulb_outline_rounded,
                  label: l10n.smartStudyApplySuggestion,
                  isPrimary: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Applying AI suggestion...'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2B7FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              _buildBookmarkButton(context, l10n),
              const SizedBox(width: 8),
              _buildSecondaryButton(
                icon: Icons.share_outlined,
                onTap: () => _shareInsight(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2B7FFF).withValues(alpha: 0.15)
                : const Color(0xFF2B7FFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: Color(0xFF2B7FFF),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark ? const Color(0xFF1E2939) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? const Color(0xFF364153)
                        : const Color(0xFFE5E7EB),
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFF101828)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isPrimary
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFFF3F4F6)
                              : const Color(0xFF101828)),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context, AppLocalizations l10n) {
    final isBookmarked = insight.isBookmarked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBookmarkToggle,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isBookmarked
                ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF1E2939) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBookmarked
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                  : (isDark
                        ? const Color(0xFF364153)
                        : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 20,
            color: isBookmarked
                ? const Color(0xFFF59E0B)
                : (isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565)),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
          ),
        ),
      ),
    );
  }

  void _shareInsight(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shareText =
        '${l10n.smartStudyAiInsight}\n\n${insight.message}\n\n- Generated by EduVerse';

    Share.share(shareText, subject: l10n.smartStudyAiInsight);
  }

  String _getTimeAgo() {
    if (insight.generatedAt == null) return 'Just now';

    final diff = DateTime.now().difference(insight.generatedAt!);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
