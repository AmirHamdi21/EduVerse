import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/instructor/shared/instructor_colors.dart';

void showExamGeneratorInfoSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBox(icon: Icons.auto_awesome_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.examGeneratorInfoTitle,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.verified_outlined,
              color: InstructorColors.success,
              text: l10n.examGeneratorInfoApprovedOnly,
            ),
            _InfoLine(
              icon: Icons.rule_outlined,
              color: InstructorColors.primary,
              text: l10n.examGeneratorInfoRules,
            ),
            _InfoLine(
              icon: Icons.edit_document,
              color: InstructorColors.accent,
              text: l10n.examGeneratorInfoDraftLifecycle,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/instructor/exam-generator/info');
                },
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.examGeneratorViewFullGuide),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ExamGeneratorInfoScreen extends StatelessWidget {
  const ExamGeneratorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(title: Text(l10n.examGeneratorInfoTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [InstructorColors.primary, InstructorColors.teal],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: InstructorColors.primary.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.examGeneratorInfoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.examGeneratorInfoIntro,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _GuideCard(
            icon: Icons.inventory_2_outlined,
            color: InstructorColors.success,
            title: l10n.examGeneratorGuidePoolTitle,
            body: l10n.examGeneratorGuidePoolBody,
          ),
          _GuideCard(
            icon: Icons.rule_folder_outlined,
            color: InstructorColors.primary,
            title: l10n.examGeneratorGuideRulesTitle,
            body: l10n.examGeneratorGuideRulesBody,
          ),
          _GuideCard(
            icon: Icons.account_tree_outlined,
            color: InstructorColors.accent,
            title: l10n.examGeneratorGuideModesTitle,
            body: l10n.examGeneratorGuideModesBody,
          ),
          _GuideCard(
            icon: Icons.edit_note_rounded,
            color: InstructorColors.orange,
            title: l10n.examGeneratorGuideLifecycleTitle,
            body: l10n.examGeneratorGuideLifecycleBody,
          ),
          _GuideCard(
            icon: Icons.tips_and_updates_outlined,
            color: InstructorColors.teal,
            title: l10n.examGeneratorGuideTipsTitle,
            body: l10n.examGeneratorGuideTipsBody,
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: InstructorColors.primary),
    );
  }
}
