import 'package:flutter/material.dart';

class ExamGeneratorFilterCard extends StatelessWidget {
  const ExamGeneratorFilterCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(spacing: 10, runSpacing: 10, children: children),
    );
  }
}
