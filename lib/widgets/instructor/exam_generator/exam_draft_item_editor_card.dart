import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_item_update_payload.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../question_bank/question_form_menu_field.dart';
import '../shared/instructor_colors.dart';

class ExamDraftItemEditorCard extends StatefulWidget {
  const ExamDraftItemEditorCard({
    super.key,
    required this.item,
    required this.sections,
    required this.onSubmit,
    this.onCancel,
  });

  final ExamDraftItemModel item;
  final List<ExamDraftSectionModel> sections;
  final ValueChanged<ExamDraftItemUpdatePayload> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ExamDraftItemEditorCard> createState() =>
      _ExamDraftItemEditorCardState();
}

class _ExamDraftItemEditorCardState extends State<ExamDraftItemEditorCard> {
  late int? _sectionId = widget.item.draftSectionId;
  late final TextEditingController _marks = TextEditingController(
    text: widget.item.marks?.toString() ?? '',
  );
  late final TextEditingController _weight = TextEditingController(
    text: widget.item.weight.toString(),
  );
  late final TextEditingController _weightUnits = TextEditingController(
    text: widget.item.weightUnits.toString(),
  );
  late final TextEditingController _override = TextEditingController(
    text: widget.item.overrideReason ?? '',
  );

  @override
  void dispose() {
    _marks.dispose();
    _weight.dispose();
    _weightUnits.dispose();
    _override.dispose();
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
              _IconBox(icon: Icons.tune_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.examEditGeneratedQuestion,
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
          QuestionFormMenuField<int?>(
            label: l10n.examMoveToSection,
            value: _sectionId,
            icon: Icons.drive_file_move_outline,
            color: InstructorColors.primary,
            options: [
              QuestionFormMenuOption<int?>(
                value: null,
                label: l10n.examUnassigned,
                icon: Icons.inbox_outlined,
              ),
              ...widget.sections.map(
                (section) => QuestionFormMenuOption<int?>(
                  value: section.id,
                  label: section.title,
                  icon: Icons.view_agenda_outlined,
                ),
              ),
            ],
            onChanged: (value) => setState(() => _sectionId = value),
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
                      label: l10n.examMarks,
                      icon: Icons.star_outline_rounded,
                      color: InstructorColors.orange,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      controller: _weight,
                      label: l10n.examMarkDistribution,
                      icon: Icons.pie_chart_outline_rounded,
                      color: InstructorColors.teal,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      controller: _weightUnits,
                      label: l10n.examWeightUnits,
                      icon: Icons.scale_outlined,
                      color: InstructorColors.accent,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          _ModernTextField(
            controller: _override,
            label: l10n.examOverrideReason,
            icon: Icons.edit_note_rounded,
            color: InstructorColors.error,
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => widget.onSubmit(
                  ExamDraftItemUpdatePayload(
                    draftSectionId: _sectionId,
                    marks: double.tryParse(_marks.text),
                    weight: double.tryParse(_weight.text),
                    weightUnits: double.tryParse(_weightUnits.text),
                    overrideReason: _override.text,
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
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
              if (widget.onCancel != null)
                OutlinedButton.icon(
                  onPressed: widget.onCancel,
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
