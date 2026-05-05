import 'package:flutter/material.dart';

import '../question_bank/question_bank_exam_screen.dart';

class InstructorExamsScreen extends StatelessWidget {
  const InstructorExamsScreen({super.key, this.initialCourseId});

  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 2,
      initialCourseId: initialCourseId,
    );
  }
}
