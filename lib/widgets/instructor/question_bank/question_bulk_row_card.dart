import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../shared/instructor_colors.dart';
import 'question_bank_localized_labels.dart';
import 'question_fill_blanks_editor.dart';
import 'question_form_menu_field.dart';
import 'question_options_editor.dart';
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
    this.isBusy = false,
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
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uniqueChapters = _uniqueChapters(chapters);
    final selectedChapterId =
        uniqueChapters.where((chapter) => chapter.id == row.chapterId).length ==
            1
        ? row.chapterId
        : null;
    final hasError = row.error?.trim().isNotEmpty == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasError
              ? InstructorColors.error.withValues(alpha: 0.55)
              : InstructorColors.borderColor(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: hasError
                    ? InstructorColors.error
                    : InstructorColors.teal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            (hasError
                                    ? InstructorColors.error
                                    : InstructorColors.primary)
                                .withValues(alpha: isDark ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        hasError
                            ? Icons.error_outline_rounded
                            : Icons.edit_note_rounded,
                        color: hasError
                            ? InstructorColors.error
                            : InstructorColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.qbQuestionRow} ${row.localId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            localizedQuestionType(l10n, row.questionType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRemove != null)
                      IconButton(
                        tooltip: l10n.remove,
                        onPressed: onRemove,
                        style: IconButton.styleFrom(
                          backgroundColor: InstructorColors.error.withValues(
                            alpha: isDark ? 0.18 : 0.1,
                          ),
                          foregroundColor: InstructorColors.error,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return QuestionFormMenuField<int>(
                      width: constraints.maxWidth,
                      label: l10n.chapter,
                      value: selectedChapterId,
                      icon: Icons.menu_book_outlined,
                      color: InstructorColors.primary,
                      enabled: uniqueChapters.isNotEmpty,
                      options: uniqueChapters
                          .map(
                            (chapter) => QuestionFormMenuOption<int>(
                              value: chapter.id,
                              label: chapter.name,
                              icon: Icons.bookmark_border_rounded,
                            ),
                          )
                          .toList(),
                      onChanged: (value) => onChanged(
                        row.copyWith(
                          chapterId: value,
                          clearChapter: value == null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: row.questionText,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _decoration(
                    context,
                    l10n.qbQuestionPrompt,
                    Icons.help_outline_rounded,
                  ),
                  onChanged: (value) =>
                      onChanged(row.copyWith(questionText: value)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: row.hints,
                  minLines: 2,
                  maxLines: 4,
                  decoration: _decoration(
                    context,
                    l10n.qbQuestionHints,
                    Icons.lightbulb_outline_rounded,
                  ),
                  onChanged: (value) => onChanged(row.copyWith(hints: value)),
                ),
                if (onUploadImage != null) ...[
                  const SizedBox(height: 12),
                  _BulkQuestionImagePanel(
                    row: row,
                    isDark: isDark,
                    isBusy: isBusy,
                    onPick: _pickQuestionImage,
                    onRemove:
                        onRemoveImage ??
                        () => onChanged(
                          row.copyWith(
                            clearQuestionFile: true,
                            questionFileCaption: '',
                            questionFileAltText: '',
                          ),
                        ),
                    onPreview: row.questionImageUrl == null
                        ? null
                        : () => _showImagePreview(
                            context,
                            imageUrl: row.questionImageUrl!,
                            title: row.questionFileCaption.trim().isNotEmpty
                                ? row.questionFileCaption
                                : '${l10n.questionBankImageQuestion}: ${row.questionFileId}',
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: row.questionFileCaption,
                    decoration: _decoration(
                      context,
                      l10n.qbImageCaption,
                      Icons.closed_caption_outlined,
                    ),
                    onChanged: (value) =>
                        onChanged(row.copyWith(questionFileCaption: value)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: row.questionFileAltText,
                    decoration: _decoration(
                      context,
                      l10n.qbImageAltText,
                      Icons.accessibility_new_outlined,
                    ),
                    onChanged: (value) =>
                        onChanged(row.copyWith(questionFileAltText: value)),
                  ),
                ],
                if (onUploadAttachments != null &&
                    onAttachmentChanged != null &&
                    onRemoveAttachment != null &&
                    onReorderAttachments != null) ...[
                  const SizedBox(height: 12),
                  QuestionPendingAttachmentManager(
                    attachments: row.attachments,
                    isUploading: isBusy,
                    onUpload: onUploadAttachments!,
                    onChanged: onAttachmentChanged!,
                    onRemove: onRemoveAttachment!,
                    onReorder: onReorderAttachments!,
                  ),
                ],
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;
                    final width = compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        QuestionFormMenuField<QuestionBankType>(
                          width: width,
                          label: l10n.type,
                          value: row.questionType,
                          icon: Icons.category_outlined,
                          color: InstructorColors.primary,
                          options: QuestionBankType.values
                              .map(
                                (type) =>
                                    QuestionFormMenuOption<QuestionBankType>(
                                      value: type,
                                      label: localizedQuestionType(l10n, type),
                                    ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) onTypeChanged(value);
                          },
                        ),
                        QuestionFormMenuField<QuestionBankDifficulty>(
                          width: width,
                          label: l10n.difficulty,
                          value: row.difficulty,
                          icon: Icons.speed_rounded,
                          color: InstructorColors.teal,
                          options: QuestionBankDifficulty.values
                              .map(
                                (value) =>
                                    QuestionFormMenuOption<
                                      QuestionBankDifficulty
                                    >(
                                      value: value,
                                      label: localizedDifficulty(l10n, value),
                                    ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              onChanged(row.copyWith(difficulty: value)),
                        ),
                        QuestionFormMenuField<BloomLevel>(
                          width: width,
                          label: l10n.qbBloomLevel,
                          value: row.bloomLevel,
                          icon: Icons.psychology_outlined,
                          color: InstructorColors.accent,
                          options: BloomLevel.values
                              .map(
                                (value) => QuestionFormMenuOption<BloomLevel>(
                                  value: value,
                                  label: localizedBloomLevel(l10n, value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              onChanged(row.copyWith(bloomLevel: value)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                _answerEditor(context, l10n),
                if (hasError) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: InstructorColors.error.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: InstructorColors.error.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      localizedQuestionBankMessage(l10n, row.error!),
                      style: const TextStyle(
                        color: InstructorColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerEditor(BuildContext context, AppLocalizations l10n) {
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
          singleCorrect: true,
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
          decoration: _decoration(context, l10n.qbAnswer, Icons.notes_rounded),
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

  Future<void> _showImagePreview(
    BuildContext context, {
    required String imageUrl,
    required String title,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: InstructorColors.primary.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: InstructorColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined, size: 64),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

class _BulkQuestionImagePanel extends StatelessWidget {
  const _BulkQuestionImagePanel({
    required this.row,
    required this.isDark,
    required this.isBusy,
    required this.onPick,
    required this.onRemove,
    this.onPreview,
  });

  final QuestionBulkRowModel row;
  final bool isDark;
  final bool isBusy;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = row.questionFileId != null;
    final label = hasImage
        ? l10n.qbReplaceQuestionImage
        : l10n.qbUploadQuestionImage;
    final color = hasImage ? InstructorColors.teal : InstructorColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onPreview ?? onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  hasImage
                      ? Icons.image_search_rounded
                      : Icons.add_photo_alternate_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasImage
                          ? '${l10n.questionBankImageQuestion} #${row.questionFileId}'
                          : l10n.image,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: label,
                onPressed: isBusy ? null : onPick,
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  foregroundColor: color,
                  minimumSize: const Size(40, 40),
                ),
                icon: Icon(
                  hasImage ? Icons.sync_rounded : Icons.upload_rounded,
                ),
              ),
              if (hasImage && onPreview != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.questionBankImageQuestion,
                  onPressed: isBusy ? null : onPreview,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.primary,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ],
              if (hasImage) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.remove,
                  onPressed: isBusy ? null : onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
