import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// AI suggestions card for staff assignment
class AiSuggestionsCard extends StatelessWidget {
  final bool isDark;
  final List<AiSuggestion> suggestions;
  final Function(AiSuggestion) onApplySuggestion;
  final VoidCallback onDismissSuggestion;

  const AiSuggestionsCard({
    super.key,
    required this.isDark,
    required this.suggestions,
    required this.onApplySuggestion,
    required this.onDismissSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E2E),
                  const Color(0xFF2D2D44),
                ]
              : [
                  const Color(0xFFFAF5FF),
                  const Color(0xFFEFF6FF),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.secondary.withValues(alpha: 0.3)
              : AdminColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiSuggestions,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.smartAssignmentRecommendations,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (suggestions.isEmpty)
            _buildEmptyState(l10n)
          else
            ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion, l10n)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AdminColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noSuggestionsNeeded,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(AiSuggestion suggestion, AppLocalizations l10n) {
    final Color typeColor;
    final IconData typeIcon;

    switch (suggestion.type) {
      case SuggestionType.assignInstructor:
        typeColor = AdminColors.secondary;
        typeIcon = Icons.person_add_rounded;
      case SuggestionType.assignTA:
        typeColor = AdminColors.accent;
        typeIcon = Icons.group_add_rounded;
      case SuggestionType.rebalance:
        typeColor = AdminColors.warning;
        typeIcon = Icons.balance_rounded;
      case SuggestionType.warning:
        typeColor = AdminColors.error;
        typeIcon = Icons.warning_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, size: 16, color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${suggestion.confidencePercent}%',
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            suggestion.description,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismissSuggestion,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.getTextSecondaryColor(isDark),
                    side: BorderSide(
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.dismiss),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () => onApplySuggestion(suggestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.apply),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum SuggestionType { assignInstructor, assignTA, rebalance, warning }

class AiSuggestion {
  final String id;
  final String title;
  final String description;
  final SuggestionType type;
  final int confidencePercent;
  final String? courseId;
  final String? staffId;

  AiSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidencePercent,
    this.courseId,
    this.staffId,
  });
}
