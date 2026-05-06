import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../question_bank/question_bank_localized_labels.dart';

class ExamDraftItemCard extends StatelessWidget {
  const ExamDraftItemCard({
    super.key,
    required this.item,
    this.onRemove,
    this.onEdit,
    this.onReplace,
    this.onOpenSource,
    this.onEditSource,
  });

  final ExamDraftItemModel item;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onReplace;
  final VoidCallback? onOpenSource;
  final VoidCallback? onEditSource;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: _thumbnail(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.question?.questionText ??
                  '${l10n.questions} ${item.questionId}',
            ),
            if (item.overrideReason != null &&
                item.overrideReason!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Chip(
                  label: Text(l10n.examOutsideOriginalRules),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        subtitle: Text(
          [
            '${localizedQuestionType(l10n, item.questionType)} • ${item.marks ?? item.weight} ${l10n.examMarks}',
            '${l10n.chapter}: ${item.chapterId}',
            '${l10n.difficulty}: ${localizedDifficulty(l10n, item.difficulty)}',
            '${l10n.qbBloomLevel}: ${localizedBloomLevel(l10n, item.bloomLevel)}',
            if (item.sourceGroupId != null)
              '${l10n.qbGroups}: ${item.sourceGroupTitle ?? item.sourceGroupId}',
            if (item.sourceQuestionStatus != null)
              '${l10n.status}: ${item.sourceQuestionStatus}',
            if (item.sourceQuestionVersionId != null)
              l10n.examVersionBadge(item.sourceQuestionVersionId!),
            if ((item.questionImagePreviewUrl ?? item.question?.questionImageUrl) != null)
              l10n.qbPromptImage,
            if (item.supportingAttachments.isNotEmpty)
              '${l10n.attachments}: ${item.supportingAttachments.length}',
          ].join('\n'),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                onOpenSource?.call();
              case 'editSource':
                onEditSource?.call();
              case 'edit':
                onEdit?.call();
              case 'replace':
                onReplace?.call();
              case 'remove':
                onRemove?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              enabled: onOpenSource != null,
              child: Text(l10n.examOpenSourceQuestion),
            ),
            PopupMenuItem(
              value: 'editSource',
              enabled: onEditSource != null,
              child: Text(l10n.examEditSourceQuestion),
            ),
            PopupMenuItem(
              value: 'edit',
              enabled: onEdit != null,
              child: Text(l10n.examEditGeneratedQuestion),
            ),
            PopupMenuItem(
              value: 'replace',
              enabled: onReplace != null,
              child: Text(l10n.examReplaceQuestion),
            ),
            PopupMenuItem(
              value: 'remove',
              enabled: onRemove != null,
              child: Text(l10n.qbRemoveRow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    final imageUrl = item.questionImagePreviewUrl ?? item.question?.questionImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        child: Icon(
          item.question?.questionFileId != null
              ? Icons.image_outlined
              : Icons.quiz_outlined,
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: InteractiveViewer(
              child: _image(imageUrl, fit: BoxFit.contain),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _image(imageUrl, width: 52, height: 52),
      ),
    );
  }

  Widget _image(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl.startsWith('data:image')) {
      final comma = imageUrl.indexOf(',');
      if (comma > -1) {
        return Image.memory(
          base64Decode(imageUrl.substring(comma + 1)),
          width: width,
          height: height,
          fit: fit,
        );
      }
    }
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          const CircleAvatar(child: Icon(Icons.image_outlined)),
    );
  }
}
