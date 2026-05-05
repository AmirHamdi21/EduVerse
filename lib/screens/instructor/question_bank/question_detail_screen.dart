import 'package:flutter/material.dart';

import 'question_bank_exam_screen.dart';

class QuestionDetailScreen extends StatelessWidget {
  const QuestionDetailScreen({
    super.key,
    required this.questionId,
    this.initialCourseId,
  });

  final int questionId;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialCourseId: initialCourseId,
      initialQuestionId: questionId,
      initialAction: QuestionBankInitialAction.viewQuestion,
    );
  }
}
