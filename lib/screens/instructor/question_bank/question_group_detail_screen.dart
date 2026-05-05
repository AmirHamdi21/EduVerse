import 'package:flutter/material.dart';

import 'question_bank_exam_screen.dart';

class QuestionGroupDetailScreen extends StatelessWidget {
  const QuestionGroupDetailScreen({
    super.key,
    required this.groupId,
    this.initialCourseId,
  });

  final int groupId;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 1,
      initialCourseId: initialCourseId,
      initialGroupId: groupId,
      initialAction: QuestionBankInitialAction.viewGroup,
    );
  }
}
