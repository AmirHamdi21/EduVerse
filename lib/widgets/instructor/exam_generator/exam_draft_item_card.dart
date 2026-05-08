import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../question_bank/question_bank_localized_labels.dart';
import '../question_bank/question_text_renderer.dart';
import '../shared/instructor_colors.dart';

class ExamDraftItemCard extends StatefulWidget {
  const ExamDraftItemCard({
    super.key,
    required this.item,
    this.orderNumber,
    this.onRemove,
    this.onEdit,
    this.onReplace,
    this.onUnassign,
    this.onOpenSource,
    this.onEditSource,
  });

  final ExamDraftItemModel item;
  final int? orderNumber;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onReplace;
  final VoidCallback? onUnassign;
  final VoidCallback? onOpenSource;
  final VoidCallback? onEditSource;

  @override
  State<ExamDraftItemCard> createState() => _ExamDraftItemCardState();
}

class _ExamDraftItemCardState extends State<ExamDraftItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = widget.item.overrideReason == null
        ? InstructorColors.primary.withValues(alpha: 0.18)
        : InstructorColors.warning.withValues(alpha: 0.34);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _expanded = !_expanded),
        onLongPress: () => _showActions(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: ColoredBox(
                  color: widget.item.overrideReason == null
                      ? InstructorColors.primary
                      : InstructorColors.warning,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuestionBadge(orderNumber: widget.orderNumber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuestionFormattedText(
                            text: widget.item.question?.questionText,
                            fallback:
                                '${l10n.questions} ${widget.item.questionId}',
                            maxLines: _expanded ? null : 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _IconAction(
                          icon: Icons.more_vert_rounded,
                          onTap: () => _showActions(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _metadataPills(context),
                    if (widget.item.overrideReason != null &&
                        widget.item.overrideReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 9),
                      _WarningStrip(text: l10n.examOutsideOriginalRules),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: InstructorColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expanded
                              ? l10n.examHideQuestionDetails
                              : l10n.examShowQuestionDetails,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _QuestionDetails(item: widget.item),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadataPills(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _InfoPill(
          label: localizedQuestionType(l10n, widget.item.questionType),
          icon: Icons.category_outlined,
          color: InstructorColors.primary,
        ),
        _InfoPill(
          label: '${widget.item.marks ?? widget.item.weight} ${l10n.examMarks}',
          icon: Icons.score_outlined,
          color: InstructorColors.orange,
        ),
        _InfoPill(
          label: '${l10n.chapter} ${widget.item.chapterId}',
          icon: Icons.menu_book_outlined,
          color: InstructorColors.teal,
        ),
        _InfoPill(
          label: localizedDifficulty(l10n, widget.item.difficulty),
          icon: Icons.speed_outlined,
          color: InstructorColors.cyan,
        ),
        _InfoPill(
          label: localizedBloomLevel(l10n, widget.item.bloomLevel),
          icon: Icons.lightbulb_outline_rounded,
          color: InstructorColors.accent,
        ),
        if (widget.item.sourceQuestionStatus != null)
          _InfoPill(
            label: widget.item.sourceQuestionStatus!,
            icon: Icons.verified_outlined,
            color: InstructorColors.success,
          ),
        if (widget.item.sourceGroupId != null)
          _InfoPill(
            label:
                widget.item.sourceGroupTitle ??
                '${l10n.qbGroups} ${widget.item.sourceGroupId}',
            icon: Icons.folder_copy_outlined,
            color: InstructorColors.accent,
          ),
        if (widget.item.supportingAttachments.isNotEmpty)
          _InfoPill(
            label:
                '${l10n.attachments}: ${widget.item.supportingAttachments.length}',
            icon: Icons.attach_file_rounded,
            color: InstructorColors.info,
          ),
      ],
    );
  }

  Future<void> _showActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InstructorColors.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _QuestionBadge(orderNumber: widget.orderNumber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.examQuestionActions,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            QuestionFormattedText(
                              text: widget.item.question?.questionText,
                              fallback:
                                  '${l10n.questions} ${widget.item.questionId}',
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SheetAction(
                    icon: Icons.open_in_new_rounded,
                    color: InstructorColors.cyan,
                    label: l10n.examOpenSourceQuestion,
                    onTap: widget.onOpenSource == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            widget.onOpenSource?.call();
                          },
                  ),
                  _SheetAction(
                    icon: Icons.edit_note_rounded,
                    color: InstructorColors.primary,
                    label: l10n.examEditSourceQuestion,
                    onTap: widget.onEditSource == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            widget.onEditSource?.call();
                          },
                  ),
                  _SheetAction(
                    icon: Icons.tune_rounded,
                    color: InstructorColors.accent,
                    label: l10n.examEditGeneratedQuestion,
                    onTap: widget.onEdit == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            widget.onEdit?.call();
                          },
                  ),
                  _SheetAction(
                    icon: Icons.swap_horiz_rounded,
                    color: InstructorColors.teal,
                    label: l10n.examReplaceQuestion,
                    onTap: widget.onReplace == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            widget.onReplace?.call();
                          },
                  ),
                  if (widget.onUnassign != null)
                    _SheetAction(
                      icon: Icons.assignment_return_outlined,
                      color: InstructorColors.orange,
                      label: l10n.examUnassignQuestion,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        widget.onUnassign?.call();
                      },
                    ),
                  _SheetAction(
                    icon: Icons.delete_outline_rounded,
                    color: InstructorColors.error,
                    label: l10n.qbRemoveRow,
                    onTap: widget.onRemove == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            widget.onRemove?.call();
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionDetails extends StatelessWidget {
  const _QuestionDetails({required this.item});

  final ExamDraftItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = item.question;
    final media = _draftQuestionMediaItems(context, item);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTitle(
              icon: Icons.fact_check_outlined,
              title: l10n.examAnswerAndDetails,
            ),
            const SizedBox(height: 10),
            if (media.isNotEmpty) ...[
              _DetailTitle(
                icon: Icons.image_outlined,
                title: l10n.examSavedQuestionMedia,
              ),
              const SizedBox(height: 8),
              for (final mediaItem in media) ...[
                _ImagePreview(imageUrl: mediaItem.url, title: mediaItem.label),
                const SizedBox(height: 10),
              ],
            ],
            if ((item.sourceGroupPrompt ?? '').trim().isNotEmpty) ...[
              _DetailTitle(
                icon: Icons.folder_copy_outlined,
                title: l10n.examSavedSourceGroupPrompt,
              ),
              const SizedBox(height: 8),
              QuestionFormattedText(text: item.sourceGroupPrompt, fallback: ''),
              const SizedBox(height: 12),
            ],
            _AnswerContent(item: item),
            if ((question?.hints ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailTitle(
                icon: Icons.lightbulb_outline_rounded,
                title: l10n.qbQuestionHints,
              ),
              const SizedBox(height: 8),
              QuestionFormattedText(
                text: question!.hints,
                fallback: l10n.examDraftNoValue,
              ),
            ],
            if (item.overrideReason != null &&
                item.overrideReason!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailTitle(
                icon: Icons.warning_amber_rounded,
                title: l10n.reason,
              ),
              const SizedBox(height: 8),
              QuestionFormattedText(
                text: item.overrideReason,
                fallback: l10n.examDraftNoValue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerContent extends StatelessWidget {
  const _AnswerContent({required this.item});

  final ExamDraftItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = item.question;
    if (question == null) {
      return _MutedMessage(text: l10n.qbNoAnswerProvided);
    }
    if (item.questionType == QuestionBankType.mcq ||
        item.questionType == QuestionBankType.trueFalse) {
      if (question.options.isEmpty) {
        return _MutedMessage(text: l10n.qbNoAnswerProvided);
      }
      return Column(
        children: [
          for (var i = 0; i < question.options.length; i++) ...[
            _AnswerOptionTile(index: i + 1, option: question.options[i]),
            if (i != question.options.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }
    if (item.questionType == QuestionBankType.fillBlanks) {
      if (question.fillBlanks.isEmpty) {
        return _MutedMessage(text: l10n.qbNoAnswerProvided);
      }
      return Column(
        children: [
          for (var i = 0; i < question.fillBlanks.length; i++) ...[
            _AnswerLine(
              icon: Icons.short_text_rounded,
              title: question.fillBlanks[i].blankKey,
              body: question.fillBlanks[i].acceptableAnswer,
              color: InstructorColors.accent,
            ),
            if (i != question.fillBlanks.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }
    return QuestionFormattedText(
      text: question.expectedAnswerText,
      fallback: l10n.qbNoAnswerProvided,
    );
  }
}

class _DraftMediaItem {
  const _DraftMediaItem({required this.url, required this.label});

  final String url;
  final String label;
}

List<_DraftMediaItem> _draftQuestionMediaItems(
  BuildContext context,
  ExamDraftItemModel item,
) {
  final l10n = AppLocalizations.of(context);
  final media = <_DraftMediaItem>[];
  final seen = <String>{};

  void add(String? url, String label) {
    final value = url?.trim();
    if (value == null || value.isEmpty || !seen.add(value)) return;
    media.add(_DraftMediaItem(url: value, label: label));
  }

  add(
    item.questionImagePreviewUrl ?? item.question?.questionImageUrl,
    item.question?.questionFileCaption ??
        item.question?.questionFileAltText ??
        l10n.questionBankImageQuestion,
  );
  for (final attachment in item.supportingAttachments) {
    add(
      attachment.previewUrl,
      attachment.caption ?? attachment.altText ?? l10n.attachments,
    );
  }
  for (final attachment in item.question?.attachments ?? const []) {
    add(
      attachment.imageUrl,
      attachment.caption ?? attachment.altText ?? l10n.attachments,
    );
  }
  add(
    item.sourceGroupImagePreviewUrl,
    item.sourceGroupTitle ?? l10n.examSavedGroupMedia,
  );

  return media;
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({required this.index, required this.option});

  final int index;
  final dynamic option;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = option.isCorrect
        ? InstructorColors.success
        : InstructorColors.textTertiaryColor(isDark);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: option.isCorrect
            ? InstructorColors.success.withValues(alpha: isDark ? 0.18 : 0.08)
            : InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: option.isCorrect
              ? InstructorColors.success.withValues(alpha: 0.28)
              : InstructorColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Icon(
            option.isCorrect
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: QuestionFormattedText(
              text: option.optionText,
              fallback: '${l10n.qbOptionNumber} $index',
            ),
          ),
          if (option.isCorrect) ...[
            const SizedBox(width: 8),
            _InfoPill(
              label: l10n.correct,
              icon: Icons.verified_rounded,
              color: InstructorColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                QuestionFormattedText(text: body, fallback: ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.16 : 0.09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                _IconBox(icon: icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: InstructorColors.textSecondaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({this.orderNumber});

  final int? orderNumber;

  @override
  Widget build(BuildContext context) {
    final label = orderNumber == null ? 'Q' : 'Q$orderNumber';
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: InstructorColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: InstructorColors.textSecondaryColor(isDark)),
      ),
    );
  }
}

class _DetailTitle extends StatelessWidget {
  const _DetailTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: InstructorColors.primary, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, this.title});

  final String imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = _imageWidget();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDraftImagePreview(context, imageUrl, title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.zoom_out_map_rounded,
                size: 16,
                color: InstructorColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title == null || title!.trim().isEmpty
                      ? l10n.examPreviewImage
                      : '${l10n.examPreviewImage} • $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageWidget({BoxFit fit = BoxFit.cover, double height = 180}) {
    if (imageUrl.startsWith('data:image')) {
      final comma = imageUrl.indexOf(',');
      if (comma > -1) {
        return Image.memory(
          base64Decode(imageUrl.substring(comma + 1)),
          width: double.infinity,
          height: height,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return _DraftImageLoadingBox(height: height);
          },
          errorBuilder: (_, __, ___) => _DraftImageErrorBox(height: height),
        );
      }
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _DraftImageLoadingBox(height: height);
      },
      errorBuilder: (_, __, ___) => _DraftImageErrorBox(height: height),
    );
  }
}

class _DraftImageLoadingBox extends StatefulWidget {
  const _DraftImageLoadingBox({required this.height});

  final double height;

  @override
  State<_DraftImageLoadingBox> createState() => _DraftImageLoadingBoxState();
}

class _DraftImageLoadingBoxState extends State<_DraftImageLoadingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: widget.height,
      alignment: Alignment.center,
      color: InstructorColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: InstructorColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftImageErrorBox extends StatelessWidget {
  const _DraftImageErrorBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: InstructorColors.textSecondaryColor(isDark),
      ),
    );
  }
}

Future<void> _showDraftImagePreview(
  BuildContext context,
  String imageUrl,
  String? title,
) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: InstructorColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title?.trim().isNotEmpty == true
                            ? title!.trim()
                            : l10n.examPreviewImage,
                        maxLines: 2,
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
                const SizedBox(height: 8),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.7,
                    maxScale: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _ImagePreview(imageUrl: imageUrl)._imageWidget(
                        fit: BoxFit.contain,
                        height: MediaQuery.sizeOf(context).height * 0.72,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningStrip extends StatelessWidget {
  const _WarningStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: InstructorColors.warning.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: InstructorColors.warning,
            size: 16,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedMessage extends StatelessWidget {
  const _MutedMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: InstructorColors.textSecondaryColor(isDark),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
