import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'assignment_card.dart';

class AssignmentsTabContent extends StatefulWidget {
  final bool isDark;

  const AssignmentsTabContent({super.key, required this.isDark});

  @override
  State<AssignmentsTabContent> createState() => _AssignmentsTabContentState();
}

class _AssignmentsTabContentState extends State<AssignmentsTabContent> {
  late List<Assignment> assignments;

  @override
  void initState() {
    super.initState();
    _initializeAssignments();
  }

  void _initializeAssignments() {
    assignments = [
      Assignment(
        id: '1',
        title: 'Assignment 1: AI Ethics Essay',
        description:
            'Write a 1500-word essay on ethical considerations in AI development.',
        dueDate: DateTime(2025, 12, 1),
        status: AssignmentStatus.completed,
        progressPercentage: 100,
      ),
      Assignment(
        id: '2',
        title: 'Assignment 2: ML Model Comparison',
        description:
            'Compare different machine learning algorithms on a dataset of your choice.',
        dueDate: DateTime(2025, 12, 8),
        status: AssignmentStatus.inProgress,
        progressPercentage: 60,
        completedQuestions: 6,
        totalQuestions: 10,
      ),
      Assignment(
        id: '3',
        title: 'Assignment 3: Final Project Proposal',
        description: 'Submit a detailed proposal for your final AI project.',
        dueDate: DateTime(2025, 12, 15),
        status: AssignmentStatus.notStarted,
        progressPercentage: 0,
        completedQuestions: 0,
        totalQuestions: 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        assignments.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == assignments.length - 1 ? 0 : 16,
          ),
          child: AssignmentCard(
            assignment: assignments[index],
            isDark: widget.isDark,
          ),
        ),
      ),
    );
  }
}
