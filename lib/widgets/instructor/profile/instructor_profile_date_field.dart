import 'package:flutter/material.dart';
import '../shared/instructor_colors.dart';

class InstructorProfileDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool isDark;
  final VoidCallback onTap;

  const InstructorProfileDateField({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: InstructorColors.textTertiaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value != null
                          ? '${value!.month}/${value!.day}/${value!.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 16,
                        color: InstructorColors.textPrimaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
