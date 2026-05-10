import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../question_bank/question_text_renderer.dart';
import '../shared/instructor_colors.dart';

Widget _reorderProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = Curves.easeOutCubic.transform(animation.value);
      return Transform.scale(
        scale: 1 + (0.015 * t),
        child: Material(
          color: Colors.transparent,
          elevation: 6 * t,
          shadowColor: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          child: child,
        ),
      );
    },
  );
}

class ExamDraftItemReorderList extends StatefulWidget {
  const ExamDraftItemReorderList({
    super.key,
    required this.items,
    required this.onSaveOrder,
    this.sections = const <ExamDraftSectionModel>[],
  });

  final List<ExamDraftItemModel> items;
  final List<ExamDraftSectionModel> sections;
  final Future<bool> Function(ExamDraftReorderPayload payload) onSaveOrder;

  @override
  State<ExamDraftItemReorderList> createState() =>
      _ExamDraftItemReorderListState();
}

class _ExamDraftItemReorderListState extends State<ExamDraftItemReorderList> {
  late List<ExamDraftItemModel> _items = _orderedItems(widget.items);
  late List<int> _sectionIds = _orderedSectionIds(widget.sections);
  final Set<int> _collapsedSectionIds = <int>{};
  bool _isSaving = false;
  bool _hasPendingChanges = false;

  @override
  void didUpdateWidget(covariant ExamDraftItemReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _orderedItems(widget.items)
        .map((item) => '${item.id}:${item.itemOrder}:${item.draftSectionId}')
        .join(',');
    final current = _items
        .map((item) => '${item.id}:${item.itemOrder}:${item.draftSectionId}')
        .join(',');
    final incomingSections = _orderedSectionIds(widget.sections).join(',');
    final currentSections = _sectionIds.join(',');
    if (!_hasPendingChanges &&
        !_isSaving &&
        (incoming != current || incomingSections != currentSections)) {
      _items = _orderedItems(widget.items);
      _sectionIds = _orderedSectionIds(widget.sections);
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
          child: _hasPendingChanges
              ? _ReorderPendingBar(
                  key: const ValueKey('pending-order'),
                  isSaving: _isSaving,
                  onSave: _savePendingOrder,
                  onReset: _resetPendingOrder,
                )
              : const SizedBox.shrink(key: ValueKey('idle-items')),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          proxyDecorator: _reorderProxyDecorator,
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
        isCollapsed: _collapsedSectionIds.contains(block.section.id),
        onToggleCollapsed: () => setState(() {
          if (!_collapsedSectionIds.add(block.section.id)) {
            _collapsedSectionIds.remove(block.section.id);
          }
        }),
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
                proxyDecorator: _reorderProxyDecorator,
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
                  canMoveUp: _canMoveUp(block.items[itemIndex].id),
                  canMoveDown: _canMoveDown(block.items[itemIndex].id),
                  onMoveUp: () => _moveQuestion(block.items[itemIndex].id, -1),
                  onMoveDown: () => _moveQuestion(block.items[itemIndex].id, 1),
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
      canMoveUp: _canMoveUp(questionBlock.item.id),
      canMoveDown: _canMoveDown(questionBlock.item.id),
      onMoveUp: () => _moveQuestion(questionBlock.item.id, -1),
      onMoveDown: () => _moveQuestion(questionBlock.item.id, 1),
    );
  }

  List<_PaperBlock> _buildBlocks() {
    final sectionById = {
      for (final section in widget.sections) section.id: section,
    };
    final consumedSections = <int>{};
    final blocks = <_PaperBlock>[];
    for (final item in _items) {
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
    for (final sectionId in _sectionIds) {
      final section = sectionById[sectionId];
      if (section != null && !consumedSections.contains(section.id)) {
        blocks.add(_SectionPaperBlock(section, const <ExamDraftItemModel>[]));
      }
    }
    return blocks;
  }

  List<ExamDraftItemModel> _itemsForSection(int sectionId) {
    return _items.where((item) => item.draftSectionId == sectionId).toList();
  }

  int _firstQuestionNumber(List<_PaperBlock> blocks, int blockIndex) {
    var count = 1;
    for (var i = 0; i < blockIndex; i++) {
      count += blocks[i].questionCount;
    }
    return count;
  }

  void _handleBlockReorder(int oldIndex, int newIndex) {
    _updateLocalOrder(() {
      final blocks = _buildBlocks();
      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      if (oldIndex == target || oldIndex >= blocks.length) return false;
      final moved = blocks.removeAt(oldIndex);
      blocks.insert(target, moved);
      return _replaceOrderFromBlocks(blocks);
    });
  }

  void _handleSectionQuestionReorder(
    int sectionId,
    int oldIndex,
    int newIndex,
  ) {
    _updateLocalOrder(() {
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
      return _replaceOrderFromBlocks(blocks);
    });
  }

  bool _canMoveUp(int itemId) {
    return _items.indexWhere((item) => item.id == itemId) > 0;
  }

  bool _canMoveDown(int itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    return index >= 0 && index < _items.length - 1;
  }

  void _moveQuestion(int itemId, int direction) {
    _updateLocalOrder(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index < 0) return false;
      final target = index + direction;
      if (target < 0 || target >= _items.length) return false;
      final items = [..._items];
      final moved = items.removeAt(index);
      items.insert(target, moved);
      _items = items;
      return true;
    });
  }

  bool _replaceOrderFromBlocks(List<_PaperBlock> blocks) {
    final flattened = <ExamDraftItemModel>[];
    final sectionIds = <int>[];
    for (final block in blocks) {
      if (block is _SectionPaperBlock) {
        sectionIds.add(block.section.id);
        flattened.addAll(block.items);
      } else if (block is _QuestionPaperBlock) {
        flattened.add(block.item);
      }
    }
    if (flattened.length != _items.length) return false;
    final oldOrder = _items.map((item) => item.id).join(',');
    final newOrder = flattened.map((item) => item.id).join(',');
    final oldSections = _sectionIds.join(',');
    final newSections = sectionIds.join(',');
    if (oldOrder == newOrder && oldSections == newSections) return false;
    _items = flattened;
    _sectionIds = sectionIds;
    return true;
  }

  void _updateLocalOrder(bool Function() updateOrder) {
    final changed = updateOrder();
    if (!changed) return;
    setState(() => _hasPendingChanges = true);
  }

  Future<void> _savePendingOrder() async {
    if (!_hasPendingChanges || _isSaving) return;
    setState(() => _isSaving = true);
    final saved = await widget.onSaveOrder(
      ExamDraftReorderPayload(
        itemIds: _items.map((item) => item.id).toList(),
        sectionIds: _sectionIds,
      ),
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved) {
        _hasPendingChanges = false;
      }
    });
  }

  void _resetPendingOrder() {
    if (_isSaving) return;
    setState(() {
      _items = _orderedItems(widget.items);
      _sectionIds = _orderedSectionIds(widget.sections);
      _hasPendingChanges = false;
    });
  }

  static List<ExamDraftItemModel> _orderedItems(
    List<ExamDraftItemModel> items,
  ) {
    return [...items]..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
  }

  static List<int> _orderedSectionIds(List<ExamDraftSectionModel> sections) {
    return ([...sections]
          ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder)))
        .map((section) => section.id)
        .toList();
  }
}

class ExamDraftReorderPayload {
  const ExamDraftReorderPayload({
    required this.itemIds,
    required this.sectionIds,
  });

  final List<int> itemIds;
  final List<int> sectionIds;
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
    required this.isCollapsed,
    required this.onToggleCollapsed,
    required this.child,
  });

  final ExamDraftSectionModel section;
  final int blockIndex;
  final int questionCount;
  final int firstQuestionNumber;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;
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
              const SizedBox(width: 8),
              Tooltip(
                message: isCollapsed
                    ? l10n.examExpandSectionQuestions
                    : l10n.examCollapseSectionQuestions,
                child: IconButton.filledTonal(
                  onPressed: onToggleCollapsed,
                  icon: AnimatedRotation(
                    turns: isCollapsed ? 0 : 0.5,
                    duration: const Duration(milliseconds: 160),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
            crossFadeState: isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
          ),
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
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    this.isGlobalBlock = false,
  });

  final ExamDraftItemModel item;
  final int order;
  final int dragIndex;
  final Color color;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final bool isGlobalBlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: Container(
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
                    clipMathToMaxLines: true,
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
            if (canMoveUp || canMoveDown) ...[
              const SizedBox(width: 8),
              _QuestionMoveControls(
                color: color,
                canMoveUp: canMoveUp,
                canMoveDown: canMoveDown,
                onMoveUp: onMoveUp,
                onMoveDown: onMoveDown,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionMoveControls extends StatelessWidget {
  const _QuestionMoveControls({
    required this.color,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final Color color;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canMoveUp)
          _MoveIconButton(
            icon: Icons.keyboard_arrow_up_rounded,
            color: color,
            onPressed: onMoveUp,
          ),
        if (canMoveUp && canMoveDown) const SizedBox(height: 6),
        if (canMoveDown)
          _MoveIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            color: color,
            onPressed: onMoveDown,
          ),
      ],
    );
  }
}

class _MoveIconButton extends StatelessWidget {
  const _MoveIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: icon == Icons.keyboard_arrow_up_rounded
          ? 'Move question up'
          : 'Move question down',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: enabled ? 1 : 0.36,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: enabled ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: enabled ? 0.22 : 0.08),
              ),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
        ),
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

class _ReorderPendingBar extends StatelessWidget {
  const _ReorderPendingBar({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.onReset,
  });

  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: InstructorColors.accent.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: InstructorColors.accent.withValues(
              alpha: isDark ? 0.12 : 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttons = Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : onReset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? l10n.savingChanges : 'Save order'),
                ),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: InstructorColors.accent.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      color: InstructorColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unsaved reorder changes',
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Review the local order, then save it once.',
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              buttons,
            ],
          );
        },
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
