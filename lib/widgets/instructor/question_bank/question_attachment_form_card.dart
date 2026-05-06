import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../shared/instructor_colors.dart';

class QuestionAttachmentFormCard extends StatefulWidget {
  const QuestionAttachmentFormCard({
    super.key,
    this.initial,
    required this.onAddByFileId,
    required this.onUpdate,
    this.onCancel,
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
  })
  onAddByFileId;
  final void Function({
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  })
  onUpdate;
  final VoidCallback? onCancel;
  final bool isSubmitting;

  @override
  State<QuestionAttachmentFormCard> createState() =>
      _QuestionAttachmentFormCardState();
}

class _QuestionAttachmentFormCardState
    extends State<QuestionAttachmentFormCard> {
  late final TextEditingController _fileId = TextEditingController(
    text: widget.initial?.fileId.toString() ?? '',
  );
  late final TextEditingController _caption = TextEditingController(
    text: widget.initial?.caption ?? '',
  );
  late final TextEditingController _alt = TextEditingController(
    text: widget.initial?.altText ?? '',
  );
  late final TextEditingController _order = TextEditingController(
    text: (widget.initial?.displayOrder ?? 0).toString(),
  );
  late final QuestionAttachmentType _type =
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editing = widget.initial != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: InstructorColors.accent.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: InstructorColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  editing ? l10n.qbEditAttachment : l10n.qbAttachmentAddByFile,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (widget.onCancel != null)
                IconButton(
                  onPressed: widget.onCancel,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.surfaceColor(isDark),
                    foregroundColor: InstructorColors.textPrimaryColor(isDark),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!editing) ...[
            TextField(
              controller: _fileId,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                context,
                l10n.qbSharedFileId,
                Icons.tag_rounded,
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _caption,
            decoration: _decoration(
              context,
              l10n.qbCaption,
              Icons.closed_caption_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alt,
            decoration: _decoration(
              context,
              l10n.qbAltText,
              Icons.accessibility_new_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _order,
            keyboardType: TextInputType.number,
            decoration: _decoration(
              context,
              l10n.qbDisplayOrder,
              Icons.format_list_numbered_rounded,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: InstructorColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 2, 8, 2),
              value: _primary,
              activeThumbColor: InstructorColors.warning,
              onChanged: (value) => setState(() => _primary = value),
              title: Text(
                l10n.qbPrimaryAttachment,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: widget.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final displayOrder = int.tryParse(_order.text) ?? 0;
    if (widget.initial != null) {
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
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}
