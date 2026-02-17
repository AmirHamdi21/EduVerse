import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// AI recommendations for role permissions
class AIRoleRecommendations extends StatelessWidget {
  final bool isDark;
  final String selectedRole;

  const AIRoleRecommendations({
    super.key,
    required this.isDark,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recommendations = _getRecommendations(selectedRole, l10n);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiRecommendations,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.basedOnUsagePatterns,
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recommendations.map((rec) => _buildRecommendationItem(rec, l10n)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(_Recommendation rec, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rec.priority == _Priority.high
              ? AdminColors.warning.withValues(alpha: 0.5)
              : (isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightDivider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: rec.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(rec.icon, size: 16, color: rec.iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rec.title,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (rec.priority == _Priority.high)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.recommended,
                    style: TextStyle(
                      color: AdminColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rec.description,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.getTextColor(isDark),
                    side: BorderSide(
                      color: isDark
                          ? AdminColors.darkCardBorder
                          : AdminColors.lightDivider,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.dismiss,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.apply,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_Recommendation> _getRecommendations(String role, AppLocalizations l10n) {
    switch (role) {
      case 'student':
        return [
          _Recommendation(
            icon: Icons.visibility_rounded,
            iconColor: AdminColors.primary,
            title: l10n.aiRecEnableViewLabs,
            description: l10n.aiRecEnableViewLabsDesc,
            priority: _Priority.high,
          ),
          _Recommendation(
            icon: Icons.assignment_rounded,
            iconColor: AdminColors.success,
            title: l10n.aiRecEnableAssignments,
            description: l10n.aiRecEnableAssignmentsDesc,
            priority: _Priority.normal,
          ),
        ];
      case 'instructor':
        return [
          _Recommendation(
            icon: Icons.grade_rounded,
            iconColor: AdminColors.warning,
            title: l10n.aiRecEnableGrading,
            description: l10n.aiRecEnableGradingDesc,
            priority: _Priority.high,
          ),
          _Recommendation(
            icon: Icons.auto_awesome_rounded,
            iconColor: AdminColors.secondary,
            title: l10n.aiRecEnableAI,
            description: l10n.aiRecEnableAIDesc,
            priority: _Priority.normal,
          ),
        ];
      case 'ta':
        return [
          _Recommendation(
            icon: Icons.grade_rounded,
            iconColor: AdminColors.warning,
            title: l10n.aiRecLimitGrading,
            description: l10n.aiRecLimitGradingDesc,
            priority: _Priority.high,
          ),
        ];
      case 'admin':
        return [
          _Recommendation(
            icon: Icons.security_rounded,
            iconColor: AdminColors.error,
            title: l10n.aiRecReviewAccess,
            description: l10n.aiRecReviewAccessDesc,
            priority: _Priority.high,
          ),
        ];
      default:
        return [];
    }
  }
}

enum _Priority { high, normal }

class _Recommendation {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final _Priority priority;

  _Recommendation({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.priority,
  });
}
