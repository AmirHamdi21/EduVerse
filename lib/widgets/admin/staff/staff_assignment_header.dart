import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Header widget for Assign Staff screen
class StaffAssignmentHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;

  const StaffAssignmentHeader({
    super.key,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AdminColors.darkCard,
                  AdminColors.darkSurface,
                ]
              : [
                  const Color(0xFFEFF6FF),
                  const Color(0xFFFAF5FF),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.darkSurface
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
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
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AdminColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AdminColors.secondaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.assignInstructorsAndTAs,
                          style: TextStyle(
                            color: AdminColors.getTextColor(isDark),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 42),
                    child: Text(
                      l10n.manageTeachingStaff,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
