import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';

class RegistrationLoadingView extends StatelessWidget {
  const RegistrationLoadingView({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 150,
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
                _line(width: 90),
                const SizedBox(height: 10),
                _line(width: double.infinity, height: 18),
                const SizedBox(height: 10),
                _line(width: 180),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(child: _line(width: double.infinity, height: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _line(width: double.infinity, height: 12)),
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
