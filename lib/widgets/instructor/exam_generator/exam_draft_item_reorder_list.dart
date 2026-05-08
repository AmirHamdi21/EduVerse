import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../question_bank/question_text_renderer.dart';
import '../shared/instructor_colors.dart';

class ExamDraftItemReorderList extends StatefulWidget {
  const ExamDraftItemReorderList({
    super.key,
    required this.items,
    required this.onReorder,
    this.sections = const <ExamDraftSectionModel>[],
  });

  final List<ExamDraftItemModel> items;
  final List<ExamDraftSectionModel> sections;
  final Future<void> Function(List<int>) onReorder;

  @override
  State<ExamDraftItemReorderList> createState() =>
      _ExamDraftItemReorderListState();
}

class _ExamDraftItemReorderListState extends State<ExamDraftItemReorderList> {
  late List<ExamDraftItemModel> _items = _orderedItems(widget.items);
  bool _isSaving = false;

  @override
  void didUpdateWidget(covariant ExamDraftItemReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _orderedItems(widget.items)
        .map((item) => '${item.id}:${item.itemOrder}:${item.draftSectionId}')
        .join(',');
    final current = _items
        .map((item) => '${item.id}:${item.itemOrder}:${item.draftSectionId}')
        .join(',');
    if (!_isSaving && incoming != current) {
      _items = _orderedItems(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_items.isEmpty && widget.sections.isEmpty) {
      return _EmptyReorderCard(
        icon: Icons.quiz_outlined,
        title: l10n.examDraftNoQuestions,
        message: l10n.examDraftNoQuestionsHint,
      );
    }
    final blocks = _buildBlocks();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: _isSaving
              ? _ReorderSavingBanner(
                  key: const ValueKey('saving-items'),
                  message: l10n.examSavingOrder,
                  color: InstructorColors.primary,
                )
              : const SizedBox.shrink(key: ValueKey('idle-items')),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: blocks.length,
          onReorder: _handleBlockReorder,
          itemBuilder: (context, index) => _blockWidget(
            context,
            block: blocks[index],
            index: index,
            firstQuestionNumber: _firstQuestionNumber(blocks, index),
          ),
        ),
      ],
    );
  }

  Widget _blockWidget(
    BuildContext context, {
    required _PaperBlock block,
    required int index,
    required int firstQuestionNumber,
  }) {
    final l10n = AppLocalizations.of(context);
    if (block is _SectionPaperBlock) {
      return _ReorderSectionBlockCard(
        key: ValueKey('block-section-${block.section.id}'),
        section: block.section,
        blockIndex: index,
        questionCount: block.items.length,
        firstQuestionNumber: firstQuestionNumber,
        child: block.items.isEmpty
            ? _EmptyReorderCard(
                icon: Icons.check_circle_outline_rounded,
                title: l10n.examSectionNoAssignedQuestions,
                message: l10n.examDraftReorderGroupedHint,
              )
            : ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: block.items.length,
                onReorder: (oldIndex, newIndex) =>
                    _handleSectionQuestionReorder(
                      block.section.id,
                      oldIndex,
                      newIndex,
                    ),
                itemBuilder: (context, itemIndex) => _ReorderQuestionTile(
                  key: ValueKey('section-item-${block.items[itemIndex].id}'),
                  item: block.items[itemIndex],
                  order: firstQuestionNumber + itemIndex,
                  dragIndex: itemIndex,
                  color: InstructorColors.primary,
                ),
              ),
      );
    }
    final questionBlock = block as _QuestionPaperBlock;
    return _ReorderQuestionTile(
      key: ValueKey('block-item-${questionBlock.item.id}'),
      item: questionBlock.item,
      order: firstQuestionNumber,
      dragIndex: index,
      isGlobalBlock: true,
      color: InstructorColors.warning,
    );
  }

  List<_PaperBlock> _buildBlocks() {
    final sectionById = {
      for (final section in widget.sections) section.id: section,
    };
    final sections = [...widget.sections]
      ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));
    final consumedSections = <int>{};
    final blocks = <_PaperBlock>[];
    for (final item in _orderedItems(_items)) {
      final sectionId = item.draftSectionId;
      final section = sectionId == null ? null : sectionById[sectionId];
      if (section == null) {
        blocks.add(_QuestionPaperBlock(item));
        continue;
      }
      if (consumedSections.add(section.id)) {
        blocks.add(_SectionPaperBlock(section, _itemsForSection(section.id)));
      }
    }
    for (final section in sections) {
      if (!consumedSections.contains(section.id)) {
        blocks.add(_SectionPaperBlock(section, const <ExamDraftItemModel>[]));
      }
    }
    return blocks;
  }

  List<ExamDraftItemModel> _itemsForSection(int sectionId) {
    return _orderedItems(
      _items.where((item) => item.draftSectionId == sectionId).toList(),
    );
  }

  int _firstQuestionNumber(List<_PaperBlock> blocks, int blockIndex) {
    var count = 1;
    for (var i = 0; i < blockIndex; i++) {
      count += blocks[i].questionCount;
    }
    return count;
  }

  Future<void> _handleBlockReorder(int oldIndex, int newIndex) async {
    await _persistOrderAfter(() {
      final blocks = _buildBlocks();
      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      if (oldIndex == target || oldIndex >= blocks.length) return false;
      final moved = blocks.removeAt(oldIndex);
      blocks.insert(target, moved);
      return _replaceItemsFromBlocks(blocks);
    });
  }

  Future<void> _handleSectionQuestionReorder(
    int sectionId,
    int oldIndex,
    int newIndex,
  ) async {
    await _persistOrderAfter(() {
      final blocks = _buildBlocks();
      final blockIndex = blocks.indexWhere(
        (block) => block is _SectionPaperBlock && block.section.id == sectionId,
      );
      if (blockIndex < 0) return false;
      final block = blocks[blockIndex] as _SectionPaperBlock;
      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      if (oldIndex == target || oldIndex >= block.items.length) return false;
      final items = [...block.items];
      final moved = items.removeAt(oldIndex);
      items.insert(target, moved);
      blocks[blockIndex] = _SectionPaperBlock(block.section, items);
      return _replaceItemsFromBlocks(blocks);
    });
  }

  bool _replaceItemsFromBlocks(List<_PaperBlock> blocks) {
    final flattened = <ExamDraftItemModel>[];
    for (final block in blocks) {
      if (block is _SectionPaperBlock) {
        flattened.addAll(block.items);
      } else if (block is _QuestionPaperBlock) {
        flattened.add(block.item);
      }
    }
    if (flattened.length != _items.length) return false;
    final oldOrder = _items.map((item) => item.id).join(',');
    final newOrder = flattened.map((item) => item.id).join(',');
    if (oldOrder == newOrder) return false;
    _items = flattened;
    return true;
  }

  Future<void> _persistOrderAfter(bool Function() updateOrder) async {
    final changed = updateOrder();
    if (!changed) return;
    setState(() {
      _isSaving = true;
    });
    try {
      await widget.onReorder(_items.map((item) => item.id).toList());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  static List<ExamDraftItemModel> _orderedItems(
    List<ExamDraftItemModel> items,
  ) {
    return [...items]..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
  }
}

abstract class _PaperBlock {
  int get questionCount;
}

class _SectionPaperBlock extends _PaperBlock {
  _SectionPaperBlock(this.section, this.items);

  final ExamDraftSectionModel section;
  final List<ExamDraftItemModel> items;

  @override
  int get questionCount => items.length;
}

class _QuestionPaperBlock extends _PaperBlock {
  _QuestionPaperBlock(this.item);

  final ExamDraftItemModel item;

  @override
  int get questionCount => 1;
}

class _ReorderSectionBlockCard extends StatelessWidget {
  const _ReorderSectionBlockCard({
    super.key,
    required this.section,
    required this.blockIndex,
    required this.questionCount,
    required this.firstQuestionNumber,
    required this.child,
  });

  final ExamDraftSectionModel section;
  final int blockIndex;
  final int questionCount;
  final int firstQuestionNumber;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rangeText = questionCount == 0
        ? l10n.examSectionNoAssignedQuestions
        : questionCount == 1
        ? l10n.examQuestionShortNumber(firstQuestionNumber)
        : '${l10n.examQuestionShortNumber(firstQuestionNumber)}-${l10n.examQuestionShortNumber(firstQuestionNumber + questionCount - 1)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: blockIndex,
                child: const Icon(
                  Icons.drag_indicator_rounded,
                  color: InstructorColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              _BucketIcon(
                icon: Icons.splitscreen_outlined,
                color: InstructorColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _Pill(label: rangeText, color: InstructorColors.accent),
                        _Pill(
                          label: l10n.examSectionAssignedQuestions(
                            questionCount,
                          ),
                          color: InstructorColors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReorderQuestionTile extends StatelessWidget {
  const _ReorderQuestionTile({
    super.key,
    required this.item,
    required this.order,
    required this.dragIndex,
    required this.color,
    this.isGlobalBlock = false,
  });

  final ExamDraftItemModel item;
  final int order;
  final int dragIndex;
  final Color color;
  final bool isGlobalBlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: dragIndex,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(Icons.drag_indicator_rounded, color: color),
            ),
          ),
          const SizedBox(width: 8),
          _QuestionOrderBadge(order: order),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionFormattedText(
                  text: item.question?.questionText,
                  fallback: '${l10n.questions} ${item.questionId}',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _Pill(
                      label: '${item.marks ?? item.weight} ${l10n.marks}',
                      color: InstructorColors.teal,
                    ),
                    if (isGlobalBlock)
                      _Pill(
                        label: l10n.examUnassignedQuestions,
                        color: InstructorColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BucketIcon extends StatelessWidget {
  const _BucketIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _QuestionOrderBadge extends StatelessWidget {
  const _QuestionOrderBadge({required this.order});

  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Q$order',
        style: const TextStyle(
          color: InstructorColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReorderSavingBanner extends StatelessWidget {
  const _ReorderSavingBanner({
    super.key,
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReorderCard extends StatelessWidget {
  const _EmptyReorderCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: InstructorColors.primary),
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
