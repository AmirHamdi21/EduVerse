import 'package:flutter/material.dart';

import '../../../models/exams/exam_draft_section_model.dart';

class ExamDraftSectionCard extends StatelessWidget {
  const ExamDraftSectionCard({super.key, required this.section, required this.children});

  final ExamDraftSectionModel section;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(section.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        if (section.instructions != null) Text(section.instructions!),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}
