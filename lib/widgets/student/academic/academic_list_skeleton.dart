import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';

class AcademicListSkeleton extends StatelessWidget {
  const AcademicListSkeleton({
    super.key,
    required this.isDark,
    this.itemCount = 4,
    this.topPadding = 16,
    this.bottomPadding = 24,
  });

  final bool isDark;
  final int itemCount;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, bottomPadding),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 168,
          decoration: BoxDecoration(
            color: StudentCoursesTheme.cardBackground(isDark),
            borderRadius: StudentCoursesTheme.cardRadius,
            border: Border.all(color: StudentCoursesTheme.borderColor(isDark)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _line(width: 84, height: 22),
                    const SizedBox(width: 8),
                    _line(width: 96, height: 22),
                  ],
                ),
                const SizedBox(height: 14),
                _line(width: double.infinity, height: 20),
                const SizedBox(height: 10),
                _line(width: 220),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: _line(width: double.infinity)),
                    const SizedBox(width: 8),
                    Expanded(child: _line(width: double.infinity)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(child: _line(width: double.infinity, height: 12)),
                    const SizedBox(width: 12),
                    _line(width: 92, height: 28),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _line({required double width, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE4E7EC),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
