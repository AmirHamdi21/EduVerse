import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'lab_card.dart';

class LabsTabContent extends StatefulWidget {
  final bool isDark;

  const LabsTabContent({
    super.key,
    required this.isDark,
  });

  @override
  State<LabsTabContent> createState() => _LabsTabContentState();
}

class _LabsTabContentState extends State<LabsTabContent> {
  late List<Lab> labs;

  @override
  void initState() {
    super.initState();
    _initializeLabs();
  }

  void _initializeLabs() {
    labs = [
      Lab(
        id: '1',
        title: 'Lab 1: Python for AI',
        description:
            'Set up your development environment and learn Python basics for AI applications.',
        dueDate: DateTime(2025, 11, 15),
        status: LabStatus.graded,
        gradePercentage: '95',
      ),
      Lab(
        id: '2',
        title: 'Lab 2: Linear Regression Implementation',
        description:
            'Implement a linear regression model from scratch using NumPy.',
        dueDate: DateTime(2025, 11, 22),
        status: LabStatus.submitted,
      ),
      Lab(
        id: '3',
        title: 'Lab 3: Neural Network Training',
        description:
            'Build and train a simple neural network for image classification.',
        dueDate: DateTime(2025, 11, 29),
        status: LabStatus.pending,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        labs.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == labs.length - 1 ? 0 : 16),
          child: LabCard(
            lab: labs[index],
            isDark: widget.isDark,
          ),
        ),
      ),
    );
  }
}
