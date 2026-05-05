import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:flutter/material.dart';

class ExamGenerationShortagePanel extends StatelessWidget {
  const ExamGenerationShortagePanel({
    super.key,
    required this.isDark,
    required this.shortages,
  });

  final bool isDark;
  final List<String> shortages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (shortages.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.warning.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InstructorColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                color: InstructorColors.warning,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.questionBankGenerationShortages,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final shortage in shortages)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(shortage),
            ),
        ],
      ),
    );
  }
}
