import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class QuestionCoreSection extends StatelessWidget {
  const QuestionCoreSection({
    super.key,
    required this.children,
    required this.title,
    this.icon = Icons.dashboard_customize_rounded,
    this.color = InstructorColors.primary,
  });

  final String title;
  final List<Widget> children;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return QuestionSectionCard(
      title: title,
      icon: icon,
      color: color,
      children: children,
    );
  }
}

class QuestionSectionCard extends StatelessWidget {
  const QuestionSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
