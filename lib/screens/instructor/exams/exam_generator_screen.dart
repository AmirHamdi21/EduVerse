import 'package:flutter/material.dart';

import '../question_bank/question_bank_exam_screen.dart';

class ExamGeneratorScreen extends StatelessWidget {
  const ExamGeneratorScreen({super.key, this.initialCourseId});

  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 2,
      initialCourseId: initialCourseId,
      initialAction: QuestionBankInitialAction.generateExam,
    );
  }
}
