import 'package:flutter/material.dart';

class QuestionCoreSection extends StatelessWidget {
  const QuestionCoreSection({
    super.key,
    required this.children,
    required this.title,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: title, icon: Icons.dashboard_customize_rounded, children: children);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF2563EB)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
