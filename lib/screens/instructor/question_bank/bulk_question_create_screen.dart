import 'package:flutter/material.dart';

import 'question_bank_exam_screen.dart';

class BulkQuestionCreateScreen extends StatelessWidget {
  const BulkQuestionCreateScreen({super.key, this.initialCourseId});

  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialCourseId: initialCourseId,
      initialAction: QuestionBankInitialAction.bulkCreateQuestions,
    );
  }
}
