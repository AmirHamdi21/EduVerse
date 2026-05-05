import 'package:flutter/material.dart';

import 'question_bank_exam_screen.dart';

class QuestionGroupsScreen extends StatelessWidget {
  const QuestionGroupsScreen({super.key, this.initialCourseId});

  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 1,
      initialCourseId: initialCourseId,
    );
  }
}
