import 'package:flutter/material.dart';

import '../../../models/exams/exam_draft_item_model.dart';

class ExamDraftItemReorderList extends StatelessWidget {
  const ExamDraftItemReorderList({
    super.key,
    required this.items,
    required this.onReorder,
  });

  final List<ExamDraftItemModel> items;
  final ValueChanged<List<int>> onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        final ids = items.map((item) => item.id).toList();
        final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final moved = ids.removeAt(oldIndex);
        ids.insert(target, moved);
        onReorder(ids);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          key: ValueKey(item.id),
          leading: const Icon(Icons.drag_indicator_rounded),
          title: Text(item.question?.questionText ?? 'Question ${item.questionId}'),
          subtitle: Text('${item.marks ?? item.weight}'),
        );
      },
    );
  }
}
