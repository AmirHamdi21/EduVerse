import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';
import 'question_core_section.dart';

class QuestionTypeSection extends StatelessWidget {
  const QuestionTypeSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return QuestionSectionCard(
      title: title,
      icon: Icons.tune_rounded,
      color: InstructorColors.accent,
      children: children,
    );
  }
}
