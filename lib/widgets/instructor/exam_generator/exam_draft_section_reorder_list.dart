import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../shared/instructor_colors.dart';

class ExamDraftSectionReorderList extends StatefulWidget {
  const ExamDraftSectionReorderList({
    super.key,
    required this.sections,
    required this.onReorder,
  });

  final List<ExamDraftSectionModel> sections;
  final Future<void> Function(List<int>) onReorder;

  @override
  State<ExamDraftSectionReorderList> createState() =>
      _ExamDraftSectionReorderListState();
}

class _ExamDraftSectionReorderListState
    extends State<ExamDraftSectionReorderList> {
  late List<ExamDraftSectionModel> _sections = List.of(widget.sections);
  bool _isSaving = false;

  @override
  void didUpdateWidget(covariant ExamDraftSectionReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.sections.map((section) => section.id).join(',');
    final current = _sections.map((section) => section.id).join(',');
    if (!_isSaving && incoming != current) {
      _sections = List.of(widget.sections);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_sections.isEmpty) {
      return _EmptyReorderCard(
        icon: Icons.view_agenda_outlined,
        title: l10n.examDraftNoSections,
        message: l10n.examDraftNoSectionsHint,
      );
    }
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: _isSaving
              ? _ReorderSavingBanner(
                  key: const ValueKey('saving-sections'),
                  message: l10n.examSavingOrder,
                  color: InstructorColors.accent,
                )
              : const SizedBox.shrink(key: ValueKey('idle-sections')),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sections.length,
          onReorder: _handleReorder,
          itemBuilder: (context, index) {
            final section = _sections[index];
            return Container(
              key: ValueKey(section.id),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: InstructorColors.borderColor(isDark)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.drag_indicator_rounded,
                    color: InstructorColors.accent,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: InstructorColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: InstructorColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.examOrderNumber(index + 1),
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (oldIndex == target) return;
    setState(() {
      final moved = _sections.removeAt(oldIndex);
      _sections.insert(target, moved);
      _isSaving = true;
    });
    try {
      await widget.onReorder(_sections.map((section) => section.id).toList());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _ReorderSavingBanner extends StatelessWidget {
  const _ReorderSavingBanner({
    super.key,
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReorderCard extends StatelessWidget {
  const _EmptyReorderCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: InstructorColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontWeight: FontWeight.w700,
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
