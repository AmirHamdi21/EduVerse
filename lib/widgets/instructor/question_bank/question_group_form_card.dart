import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import 'question_bank_localized_labels.dart';

class QuestionGroupFormCard extends StatefulWidget {
  const QuestionGroupFormCard({
    super.key,
    this.initial,
    required this.courseId,
    required this.onSubmit,
    this.onUploadSharedImage,
    this.isSubmitting = false,
  });

  final QuestionBankGroupModel? initial;
  final int? courseId;
  final void Function({
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    required QuestionGroupType groupType,
  })
  onSubmit;
  final Future<int?> Function(String path)? onUploadSharedImage;
  final bool isSubmitting;

  @override
  State<QuestionGroupFormCard> createState() => _QuestionGroupFormCardState();
}

class _QuestionGroupFormCardState extends State<QuestionGroupFormCard> {
  late QuestionGroupType _type =
      widget.initial?.groupType ?? QuestionGroupType.other;
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? '',
  );
  late final TextEditingController _prompt = TextEditingController(
    text: widget.initial?.sharedPrompt ?? '',
  );
  late final TextEditingController _caption = TextEditingController(
    text: widget.initial?.sharedFileCaption ?? '',
  );
  late final TextEditingController _altText = TextEditingController(
    text: widget.initial?.sharedFileAltText ?? '',
  );
  late int? _sharedFileId = widget.initial?.sharedFileId;
  bool _isUploading = false;

  @override
  void dispose() {
    _title.dispose();
    _prompt.dispose();
    _caption.dispose();
    _altText.dispose();
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
            widget.initial == null ? l10n.qbCreateGroup : l10n.qbEditGroup,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: l10n.title,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prompt,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n.qbSharedPrompt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onUploadSharedImage == null || _isUploading
                ? null
                : _pickSharedImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _sharedFileId == null
                  ? l10n.qbUploadGroupImage
                  : '${l10n.qbGroupImage}: $_sharedFileId',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caption,
            decoration: InputDecoration(
              labelText: l10n.qbImageCaption,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _altText,
            decoration: InputDecoration(
              labelText: l10n.qbImageAltText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<QuestionGroupType>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: l10n.qbGroupType,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: QuestionGroupType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(localizedGroupType(l10n, type)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.isSubmitting || widget.courseId == null
                ? null
                : () => widget.onSubmit(
                    title: _title.text,
                    sharedPrompt: _prompt.text,
                    sharedFileId: _sharedFileId,
                    sharedFileCaption: _caption.text,
                    sharedFileAltText: _altText.text,
                    groupType: _type,
                  ),
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSharedImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path == null || widget.onUploadSharedImage == null) return;
    setState(() => _isUploading = true);
    final fileId = await widget.onUploadSharedImage!(path);
    if (!mounted) return;
    setState(() {
      _sharedFileId = fileId ?? _sharedFileId;
      _isUploading = false;
    });
  }
}
