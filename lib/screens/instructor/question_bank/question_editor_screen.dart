import 'package:flutter/material.dart';

import 'question_bank_exam_screen.dart';

class QuestionEditorScreen extends StatelessWidget {
  const QuestionEditorScreen({
    super.key,
    this.questionId,
    this.initialCourseId,
  });

  final int? questionId;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialCourseId: initialCourseId,
      initialQuestionId: questionId,
      initialAction: questionId == null
          ? QuestionBankInitialAction.createQuestion
          : QuestionBankInitialAction.editQuestion,
    );
  }
}
