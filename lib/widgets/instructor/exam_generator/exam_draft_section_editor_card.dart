import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../../../models/exams/exam_draft_section_payload.dart';
import '../../../models/exams/exam_generator_enums.dart';
import 'exam_generator_localized_labels.dart';

class ExamDraftSectionEditorCard extends StatefulWidget {
  const ExamDraftSectionEditorCard({
    super.key,
    this.initial,
    required this.onSubmit,
    this.onCancel,
  });

  final ExamDraftSectionModel? initial;
  final ValueChanged<ExamDraftSectionPayload> onSubmit;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.title),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructions,
              decoration: InputDecoration(labelText: l10n.instructions),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _marks,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.totalMarks),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExamSectionAnswerPolicy>(
              initialValue: _policy,
              decoration: InputDecoration(labelText: l10n.examAnswerPolicy),
              items: ExamSectionAnswerPolicy.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(localizedAnswerPolicy(l10n, value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _policy = value ?? _policy),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _required,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.examRequiredAnswerCount,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                FilledButton(
                  onPressed: () => widget.onSubmit(
                    ExamDraftSectionPayload(
                      title: _title.text,
                      instructions: _instructions.text,
                      totalMarks: double.tryParse(_marks.text),
                      answerPolicy: _policy,
                      requiredAnswerCount: int.tryParse(_required.text),
                    ),
                  ),
                  child: Text(l10n.save),
                ),
                if (widget.onCancel != null)
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.cancel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
