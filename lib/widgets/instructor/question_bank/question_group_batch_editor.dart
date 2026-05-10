import 'package:flutter/material.dart';

import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import 'question_bulk_editor.dart';
import 'question_bulk_row_card.dart';

class QuestionGroupBatchEditor extends StatelessWidget {
  const QuestionGroupBatchEditor({
    super.key,
    required this.rows,
    required this.chapters,
    required this.onChanged,
    required this.onAddRow,
    required this.onRemoveRow,
    this.onUploadImage,
    this.onRemoveImage,
    this.onUploadAttachments,
    this.onAttachmentChanged,
    this.onRemoveAttachment,
    this.onReorderAttachments,
    this.collapsedRowIds = const <int>{},
    this.onToggleCollapsed,
    this.isBusy = false,
  });

  final List<QuestionBulkRowModel> rows;
  final List<CourseChapterModel> chapters;
  final ValueChanged<QuestionBulkRowModel> onChanged;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final void Function(int localId, String path)? onUploadImage;
  final ValueChanged<QuestionBulkRowModel>? onRemoveImage;
  final void Function(int localId, List<String> paths)? onUploadAttachments;
  final void Function(int localId, QuestionAttachmentPayload attachment)?
  onAttachmentChanged;
  final void Function(int localId, int fileId)? onRemoveAttachment;
  final void Function(int localId, List<int> orderedFileIds)?
  onReorderAttachments;
  final Set<int> collapsedRowIds;
  final ValueChanged<int>? onToggleCollapsed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return QuestionBulkEditor(
      rowCount: rows.length,
      onAddRow: onAddRow,
      children: rows
          .map(
            (row) => QuestionBulkRowCard(
              row: row,
              chapters: chapters,
              isBusy: isBusy,
              onChanged: onChanged,
              onTypeChanged: (type) => onChanged(_rowForType(row, type)),
              onUploadImage: onUploadImage == null
                  ? null
                  : (path) => onUploadImage!(row.localId, path),
              onRemoveImage: row.questionFileId == null
                  ? null
                  : () => onRemoveImage?.call(row),
              onUploadAttachments: onUploadAttachments == null
                  ? null
                  : (paths) => onUploadAttachments!(row.localId, paths),
              onAttachmentChanged: onAttachmentChanged == null
                  ? null
                  : (attachment) =>
                        onAttachmentChanged!(row.localId, attachment),
              onRemoveAttachment: onRemoveAttachment == null
                  ? null
                  : (fileId) => onRemoveAttachment!(row.localId, fileId),
              onReorderAttachments: onReorderAttachments == null
                  ? null
                  : (ids) => onReorderAttachments!(row.localId, ids),
              onRemove: rows.length <= 1
                  ? null
                  : () => onRemoveRow(row.localId),
              isCollapsed: collapsedRowIds.contains(row.localId),
              onToggleCollapsed: onToggleCollapsed == null
                  ? null
                  : () => onToggleCollapsed!(row.localId),
            ),
          )
          .toList(),
    );
  }

  QuestionBulkRowModel _rowForType(
    QuestionBulkRowModel row,
    QuestionBankType type,
  ) {
    return row.copyWith(
      questionType: type,
      options: _optionsForType(type, row.options),
      fillBlanks: type == QuestionBankType.fillBlanks
          ? (row.fillBlanks.isEmpty
                ? const [
                    QuestionBankFillBlankModel(
                      blankKey: 'blank1',
                      acceptableAnswer: '',
                    ),
                  ]
                : row.fillBlanks)
          : const [],
      expectedAnswerText:
          (type == QuestionBankType.written || type == QuestionBankType.essay)
          ? row.expectedAnswerText
          : '',
    );
  }

  List<QuestionBankOptionModel> _optionsForType(
    QuestionBankType type,
    List<QuestionBankOptionModel> existing,
  ) {
    switch (type) {
      case QuestionBankType.mcq:
        return const [
          QuestionBankOptionModel(optionText: '', isCorrect: true),
          QuestionBankOptionModel(optionText: '', isCorrect: false),
        ];
      case QuestionBankType.trueFalse:
        return const [
          QuestionBankOptionModel(optionText: 'True', isCorrect: true),
          QuestionBankOptionModel(optionText: 'False', isCorrect: false),
        ];
      case QuestionBankType.fillBlanks:
      case QuestionBankType.written:
      case QuestionBankType.essay:
        return const [];
    }
  }
}
