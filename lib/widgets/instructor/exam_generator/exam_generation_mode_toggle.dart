import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_form_model.dart';
import '../shared/instructor_colors.dart';

class ExamGenerationModeToggle extends StatelessWidget {
  const ExamGenerationModeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ExamGenerationMode value;
  final ValueChanged<ExamGenerationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: InstructorColors.teal.withValues(
                    alpha: isDark ? 0.18 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: InstructorColors.teal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.examCreateModeTitle,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = constraints.maxWidth < 430 ? 8.0 : 10.0;
              final width = constraints.maxWidth < 430
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: _ModeTile(
                      selected: value == ExamGenerationMode.flat,
                      title: l10n.examSimpleMode,
                      subtitle: l10n.examSimpleModeHelp,
                      icon: Icons.rule_outlined,
                      color: InstructorColors.primary,
                      onTap: () => onChanged(ExamGenerationMode.flat),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModeTile(
                      selected: value == ExamGenerationMode.sectioned,
                      title: l10n.examSectionedMode,
                      subtitle: l10n.examSectionedModeHelp,
                      icon: Icons.view_agenda_outlined,
                      color: InstructorColors.accent,
                      onTap: () => onChanged(ExamGenerationMode.sectioned),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.18 : 0.1)
              : InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : InstructorColors.borderColor(isDark),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? color
                                : InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected
                            ? color
                            : InstructorColors.textTertiaryColor(isDark),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.22,
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
