import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../../../models/exams/exam_draft_section_payload.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../question_bank/question_form_menu_field.dart';
import '../shared/instructor_colors.dart';
import 'exam_generator_localized_labels.dart';

class ExamDraftSectionEditorCard extends StatefulWidget {
  const ExamDraftSectionEditorCard({
    super.key,
    this.initial,
    required this.onSubmit,
    this.isSubmitting = false,
    this.onCancel,
  });

  final ExamDraftSectionModel? initial;
  final Future<void> Function(ExamDraftSectionPayload) onSubmit;
  final bool isSubmitting;
  final VoidCallback? onCancel;

  @override
  State<ExamDraftSectionEditorCard> createState() =>
      _ExamDraftSectionEditorCardState();
}

class _ExamDraftSectionEditorCardState
    extends State<ExamDraftSectionEditorCard> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? '',
  );
  late final TextEditingController _instructions = TextEditingController(
    text: widget.initial?.instructions ?? '',
  );
  late final TextEditingController _marks = TextEditingController(
    text: widget.initial?.totalMarks?.toString() ?? '',
  );
  late final TextEditingController _required = TextEditingController(
    text: widget.initial?.requiredAnswerCount?.toString() ?? '',
  );
  late ExamSectionAnswerPolicy _policy =
      widget.initial?.answerPolicy ?? ExamSectionAnswerPolicy.answerAll;

  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    _marks.dispose();
    _required.dispose();
    super.dispose();
  }

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
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.view_agenda_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.initial == null
                      ? l10n.examCreateSection
                      : l10n.examEditSection,
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
          _ModernTextField(
            controller: _title,
            label: l10n.title,
            icon: Icons.title_rounded,
            color: InstructorColors.primary,
          ),
          const SizedBox(height: 10),
          _ModernTextField(
            controller: _instructions,
            label: l10n.instructions,
            icon: Icons.notes_rounded,
            color: InstructorColors.accent,
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 560;
              final width = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      controller: _marks,
                      label: l10n.totalMarks,
                      icon: Icons.star_outline_rounded,
                      color: InstructorColors.orange,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<ExamSectionAnswerPolicy>(
                      label: l10n.examAnswerPolicy,
                      value: _policy,
                      icon: Icons.rule_rounded,
                      color: InstructorColors.teal,
                      options: ExamSectionAnswerPolicy.values
                          .map(
                            (value) => QuestionFormMenuOption(
                              value: value,
                              label: localizedAnswerPolicy(l10n, value),
                              icon: Icons.rule_rounded,
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _policy = value ?? _policy),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      controller: _required,
                      label: l10n.examRequiredAnswerCount,
                      icon: Icons.format_list_numbered_rounded,
                      color: InstructorColors.primary,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: widget.isSubmitting
                    ? null
                    : () => widget.onSubmit(
                        ExamDraftSectionPayload(
                          title: _title.text,
                          instructions: _instructions.text,
                          totalMarks: double.tryParse(_marks.text),
                          answerPolicy: _policy,
                          requiredAnswerCount: int.tryParse(_required.text),
                        ),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: widget.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  widget.isSubmitting ? l10n.examSavingOrder : l10n.save,
                ),
              ),
              if (widget.onCancel != null)
                OutlinedButton.icon(
                  onPressed: widget.isSubmitting ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.error,
                    side: BorderSide(
                      color: InstructorColors.error.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.cancel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        filled: true,
        fillColor: InstructorColors.surfaceColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: InstructorColors.primary),
    );
  }
}
