import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import 'question_fill_blanks_editor.dart';
import 'question_options_editor.dart';
import 'question_bank_localized_labels.dart';
import 'question_pending_attachment_manager.dart';

class QuestionBulkRowCard extends StatelessWidget {
  const QuestionBulkRowCard({
    super.key,
    required this.row,
    required this.chapters,
    required this.onChanged,
    required this.onTypeChanged,
    this.onUploadImage,
    this.onRemoveImage,
    this.onUploadAttachments,
    this.onAttachmentChanged,
    this.onRemoveAttachment,
    this.onReorderAttachments,
    this.onRemove,
  });

  final QuestionBulkRowModel row;
  final List<CourseChapterModel> chapters;
  final ValueChanged<QuestionBulkRowModel> onChanged;
  final ValueChanged<QuestionBankType> onTypeChanged;
  final ValueChanged<String>? onUploadImage;
  final VoidCallback? onRemoveImage;
  final ValueChanged<List<String>>? onUploadAttachments;
  final ValueChanged<QuestionAttachmentPayload>? onAttachmentChanged;
  final ValueChanged<int>? onRemoveAttachment;
  final ValueChanged<List<int>>? onReorderAttachments;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uniqueChapters = _uniqueChapters(chapters);
    final selectedChapterId =
        uniqueChapters.where((chapter) => chapter.id == row.chapterId).length ==
            1
        ? row.chapterId
        : null;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: row.error == null
              ? const Color(0xFFE5E7EB)
              : Theme.of(context).colorScheme.error,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.qbQuestionRow} ${row.localId}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _box(
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedChapterId,
                    decoration: InputDecoration(labelText: l10n.chapter),
                    items: uniqueChapters
                        .map(
                          (chapter) => DropdownMenuItem(
                            value: chapter.id,
                            child: Text(
                              chapter.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => onChanged(
                      row.copyWith(
                        chapterId: value,
                        clearChapter: value == null,
                      ),
                    ),
                  ),
                ),
                _box(
                  DropdownButtonFormField<QuestionBankType>(
                    isExpanded: true,
                    initialValue: row.questionType,
                    decoration: InputDecoration(labelText: l10n.type),
                    items: QuestionBankType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(localizedQuestionType(l10n, type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onTypeChanged(value);
                    },
                  ),
                ),
                _box(
                  DropdownButtonFormField<QuestionBankDifficulty>(
                    initialValue: row.difficulty,
                    decoration: InputDecoration(labelText: l10n.difficulty),
                    items: QuestionBankDifficulty.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(localizedDifficulty(l10n, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        onChanged(row.copyWith(difficulty: value)),
                  ),
                ),
                _box(
                  DropdownButtonFormField<BloomLevel>(
                    initialValue: row.bloomLevel,
                    decoration: InputDecoration(labelText: l10n.qbBloomLevel),
                    items: BloomLevel.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(localizedBloomLevel(l10n, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        onChanged(row.copyWith(bloomLevel: value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: row.questionText,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.questionBankSearchQuestionTextOnly,
              ),
              onChanged: (value) =>
                  onChanged(row.copyWith(questionText: value)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: row.hints,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.qbQuestionHints),
              onChanged: (value) => onChanged(row.copyWith(hints: value)),
            ),
            const SizedBox(height: 12),
            if (onUploadImage != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickQuestionImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      row.questionFileId == null
                          ? l10n.qbUploadQuestionImage
                          : '${l10n.questionBankImageQuestion}: ${row.questionFileId}',
                    ),
                  ),
                  if (row.questionFileId != null)
                    IconButton.outlined(
                      tooltip: l10n.qbRemoveQuestionImage,
                      onPressed:
                          onRemoveImage ??
                          () => onChanged(
                            row.copyWith(
                              clearQuestionFile: true,
                              questionFileCaption: '',
                              questionFileAltText: '',
                            ),
                          ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
              if (row.questionFileId != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.questionBankImageQuestion}: ${row.questionFileId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                initialValue: row.questionFileCaption,
                decoration: InputDecoration(labelText: l10n.qbImageCaption),
                onChanged: (value) =>
                    onChanged(row.copyWith(questionFileCaption: value)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: row.questionFileAltText,
                decoration: InputDecoration(labelText: l10n.qbImageAltText),
                onChanged: (value) =>
                    onChanged(row.copyWith(questionFileAltText: value)),
              ),
              const SizedBox(height: 12),
            ],
            if (onUploadAttachments != null &&
                onAttachmentChanged != null &&
                onRemoveAttachment != null &&
                onReorderAttachments != null) ...[
              const SizedBox(height: 12),
              QuestionPendingAttachmentManager(
                attachments: row.attachments,
                onUpload: onUploadAttachments!,
                onChanged: onAttachmentChanged!,
                onRemove: onRemoveAttachment!,
                onReorder: onReorderAttachments!,
              ),
            ],
            _answerEditor(l10n),
            if (row.error != null) ...[
              const SizedBox(height: 8),
              Text(
                row.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _box(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: child,
    );
  }

  Widget _answerEditor(AppLocalizations l10n) {
    switch (row.questionType) {
      case QuestionBankType.mcq:
        return QuestionOptionsEditor(
          key: ValueKey('mcq-${row.localId}'),
          options: row.options.isEmpty ? _defaultMcqOptions : row.options,
          onChanged: (options) => onChanged(row.copyWith(options: options)),
        );
      case QuestionBankType.trueFalse:
        return QuestionOptionsEditor(
          key: ValueKey('tf-${row.localId}'),
          lockCount: true,
          options: row.options.length == 2
              ? row.options
              : _defaultTrueFalseOptions,
          onChanged: (options) => onChanged(row.copyWith(options: options)),
        );
      case QuestionBankType.fillBlanks:
        return QuestionFillBlanksEditor(
          key: ValueKey('blank-${row.localId}'),
          blanks: row.fillBlanks,
          onChanged: (blanks) => onChanged(row.copyWith(fillBlanks: blanks)),
        );
      case QuestionBankType.written:
      case QuestionBankType.essay:
        return TextFormField(
          key: ValueKey('answer-${row.localId}-${row.questionType.value}'),
          initialValue: row.expectedAnswerText,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.qbAnswer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onChanged: (value) =>
              onChanged(row.copyWith(expectedAnswerText: value)),
        );
    }
  }

  Future<void> _pickQuestionImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path != null) onUploadImage?.call(path);
  }

  List<CourseChapterModel> _uniqueChapters(List<CourseChapterModel> source) {
    final seen = <int>{};
    return [
      for (final chapter in source)
        if (seen.add(chapter.id)) chapter,
    ];
  }

  static const _defaultMcqOptions = [
    QuestionBankOptionModel(optionText: '', isCorrect: true),
    QuestionBankOptionModel(optionText: '', isCorrect: false),
  ];

  static const _defaultTrueFalseOptions = [
    QuestionBankOptionModel(optionText: 'True', isCorrect: true),
    QuestionBankOptionModel(optionText: 'False', isCorrect: false),
  ];
}
