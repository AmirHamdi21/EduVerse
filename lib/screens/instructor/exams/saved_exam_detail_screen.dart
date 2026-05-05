import 'package:flutter/material.dart';

import '../question_bank/question_bank_exam_screen.dart';

class SavedExamDetailScreen extends StatelessWidget {
  const SavedExamDetailScreen({
    super.key,
    required this.examId,
    this.initialCourseId,
  });

  final int examId;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 2,
      initialCourseId: initialCourseId,
      initialExamId: examId,
      initialAction: QuestionBankInitialAction.viewSavedExam,
    );
  }
}
