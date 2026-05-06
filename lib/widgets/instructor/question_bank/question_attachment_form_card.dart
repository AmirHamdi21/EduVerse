import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import 'question_bank_localized_labels.dart';

class QuestionAttachmentFormCard extends StatefulWidget {
  const QuestionAttachmentFormCard({
    super.key,
    this.initial,
    required this.onAddByFileId,
    required this.onUpdate,
    this.isSubmitting = false,
  });

  final QuestionBankAttachmentModel? initial;
  final void Function({
    required int fileId,
    required QuestionAttachmentType attachmentType,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) onAddByFileId;
  final void Function({
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) onUpdate;
  final bool isSubmitting;

  @override
  State<QuestionAttachmentFormCard> createState() => _QuestionAttachmentFormCardState();
}

class _QuestionAttachmentFormCardState extends State<QuestionAttachmentFormCard> {
  late final TextEditingController _fileId =
      TextEditingController(text: widget.initial?.fileId.toString() ?? '');
  late final TextEditingController _caption =
      TextEditingController(text: widget.initial?.caption ?? '');
  late final TextEditingController _alt =
      TextEditingController(text: widget.initial?.altText ?? '');
  late final TextEditingController _order =
      TextEditingController(text: (widget.initial?.displayOrder ?? 0).toString());
  late QuestionAttachmentType _type =
      widget.initial?.attachmentType ?? QuestionAttachmentType.image;
  late bool _primary = widget.initial?.isPrimary ?? false;

  @override
  void dispose() {
    _fileId.dispose();
    _caption.dispose();
    _alt.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editing = widget.initial != null;
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
            editing ? l10n.qbEditAttachment : l10n.qbAttachmentAddByFile,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (!editing)
            TextField(
              controller: _fileId,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.qbSharedFileId,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          if (!editing) const SizedBox(height: 12),
          DropdownButtonFormField<QuestionAttachmentType>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: l10n.type,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: QuestionAttachmentType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(localizedAttachmentType(l10n, type)),
                    ))
                .toList(),
            onChanged: editing ? null : (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caption,
            decoration: InputDecoration(
              labelText: l10n.qbCaption,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alt,
            decoration: InputDecoration(
              labelText: l10n.qbAltText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _order,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.qbDisplayOrder,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _primary,
            onChanged: (value) => setState(() => _primary = value),
            title: Text(l10n.qbPrimaryAttachment),
          ),
          FilledButton.icon(
            onPressed: widget.isSubmitting
                ? null
                : () {
                    final displayOrder = int.tryParse(_order.text) ?? 0;
                    if (editing) {
                      widget.onUpdate(
                        attachmentId: widget.initial!.attachmentId,
                        caption: _caption.text,
                        altText: _alt.text,
                        displayOrder: displayOrder,
                        isPrimary: _primary,
                      );
                    } else {
                      widget.onAddByFileId(
                        fileId: int.tryParse(_fileId.text) ?? 0,
                        attachmentType: _type,
                        caption: _caption.text,
                        altText: _alt.text,
                        displayOrder: displayOrder,
                        isPrimary: _primary,
                      );
                    }
                  },
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
