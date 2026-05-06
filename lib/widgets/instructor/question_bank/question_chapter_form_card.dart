import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';

class QuestionChapterFormCard extends StatefulWidget {
  const QuestionChapterFormCard({
    super.key,
    this.initial,
    this.suggestedOrder,
    required this.onSubmit,
    this.onCancel,
    this.isSubmitting = false,
  });

  final CourseChapterModel? initial;
  final int? suggestedOrder;
  final void Function(String name, int order, bool isActive) onSubmit;
  final VoidCallback? onCancel;
  final bool isSubmitting;

  @override
  State<QuestionChapterFormCard> createState() => _QuestionChapterFormCardState();
}

class _QuestionChapterFormCardState extends State<QuestionChapterFormCard> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _order = TextEditingController(
    text: (widget.initial?.chapterOrder ?? widget.suggestedOrder ?? 1)
        .toString(),
  );
  late bool _isActive = widget.initial?.isActive ?? true;

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initial == null ? l10n.qbCreateChapter : l10n.qbEditChapter,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.qbChapterName,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _order,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.qbChapterOrder,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          if (widget.initial != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              title: Text(l10n.qbChapterActive),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: widget.isSubmitting
                    ? null
                    : () => widget.onSubmit(
                          _name.text,
                          int.tryParse(_order.text) ?? 1,
                          _isActive,
                        ),
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
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
    );
  }
}
