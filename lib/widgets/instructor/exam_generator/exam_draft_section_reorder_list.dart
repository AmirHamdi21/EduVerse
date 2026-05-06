import 'package:flutter/material.dart';

import '../../../models/exams/exam_draft_section_model.dart';

class ExamDraftSectionReorderList extends StatelessWidget {
  const ExamDraftSectionReorderList({
    super.key,
    required this.sections,
    required this.onReorder,
  });

  final List<ExamDraftSectionModel> sections;
  final ValueChanged<List<int>> onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      onReorder: (oldIndex, newIndex) {
        final ids = sections.map((section) => section.id).toList();
        final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final moved = ids.removeAt(oldIndex);
        ids.insert(target, moved);
        onReorder(ids);
      },
      itemBuilder: (context, index) {
        final section = sections[index];
        return ListTile(
          key: ValueKey(section.id),
          leading: const Icon(Icons.drag_indicator_rounded),
          title: Text(section.title),
          subtitle: Text(section.sectionOrder.toString()),
        );
      },
    );
  }
}
