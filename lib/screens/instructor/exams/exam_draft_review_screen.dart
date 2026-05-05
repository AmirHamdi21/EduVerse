import 'package:flutter/material.dart';

import '../question_bank/question_bank_exam_screen.dart';

class ExamDraftReviewScreen extends StatelessWidget {
  const ExamDraftReviewScreen({
    super.key,
    required this.draftId,
    this.initialCourseId,
  });

  final int draftId;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    return QuestionBankExamScreen(
      initialTabIndex: 2,
      initialCourseId: initialCourseId,
      initialDraftId: draftId,
      initialAction: QuestionBankInitialAction.reviewDraft,
    );
  }
}
