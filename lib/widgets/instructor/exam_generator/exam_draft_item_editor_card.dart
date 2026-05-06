import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_item_update_payload.dart';
import '../../../models/exams/exam_draft_section_model.dart';

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
  State<ExamDraftItemEditorCard> createState() => _ExamDraftItemEditorCardState();
}

class _ExamDraftItemEditorCardState extends State<ExamDraftItemEditorCard> {
  late int? _sectionId = widget.item.draftSectionId;
  late final TextEditingController _marks =
      TextEditingController(text: widget.item.marks?.toString() ?? '');
  late final TextEditingController _weight =
      TextEditingController(text: widget.item.weight.toString());
  late final TextEditingController _weightUnits =
      TextEditingController(text: widget.item.weightUnits.toString());
  late final TextEditingController _override =
      TextEditingController(text: widget.item.overrideReason ?? '');

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _sectionId,
              decoration: InputDecoration(labelText: l10n.examMoveToSection),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.examUnassigned)),
                ...widget.sections.map((section) => DropdownMenuItem<int?>(
                      value: section.id,
                      child: Text(section.title),
                    )),
              ],
              onChanged: (value) => setState(() => _sectionId = value),
            ),
            const SizedBox(height: 12),
            TextField(controller: _marks, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.examMarks)),
            const SizedBox(height: 12),
            TextField(controller: _weight, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.examMarkDistribution)),
            const SizedBox(height: 12),
            TextField(controller: _weightUnits, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.examWeightUnits)),
            const SizedBox(height: 12),
            TextField(controller: _override, decoration: InputDecoration(labelText: l10n.examOverrideReason)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                FilledButton(
                  onPressed: () => widget.onSubmit(ExamDraftItemUpdatePayload(
                    draftSectionId: _sectionId,
                    marks: double.tryParse(_marks.text),
                    weight: double.tryParse(_weight.text),
                    weightUnits: double.tryParse(_weightUnits.text),
                    overrideReason: _override.text,
                  )),
                  child: Text(l10n.save),
                ),
                if (widget.onCancel != null)
                  OutlinedButton(onPressed: widget.onCancel, child: Text(l10n.cancel)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
