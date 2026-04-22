import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/flashcard_model.dart';

class CourseSelector extends StatelessWidget {
  final List<Course> courses;
  final Course selectedCourse;
  final bool isDark;
  final Function(Course) onCourseSelected;

  const CourseSelector({
    super.key,
    required this.courses,
    required this.selectedCourse,
    required this.isDark,
    required this.onCourseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final borderColor = isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFD1D5DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).selectCourse,
          style: TextStyle(
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: responsive.p12),
        GestureDetector(
          onTap: () {
            _showCourseBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p16,
              vertical: responsive.p12,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(responsive.radius16),
              color: isDark ? const Color(0xFF252D48) : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: responsive.p32,
                  height: responsive.p32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8F1FF),
                  ),
                  child: Center(
                    child: Text(
                      selectedCourse.icon,
                      style: TextStyle(fontSize: responsive.fontSize16),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Text(
                    selectedCourse.name,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: borderColor,
                  size: responsive.iconSmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCourseBottomSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    final responsive = context.responsive;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final cardColor = isDark ? const Color(0xFF252D48) : Colors.white;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: Text(
                AppLocalizations.of(context).selectCourse,
                style: TextStyle(
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final isSelected = course.id == selectedCourse.id;

                  return GestureDetector(
                    onTap: () {
                      onCourseSelected(course);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: responsive.p16,
                        vertical: responsive.p8,
                      ),
                      padding: EdgeInsets.all(responsive.p12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                        color: isSelected ? const Color(0xFFE8F1FF) : cardColor,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2B7FFF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: responsive.p40,
                            height: responsive.p40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF2B7FFF)
                                  : const Color(0xFFE8F1FF),
                            ),
                            child: Center(
                              child: Text(
                                course.icon,
                                style: TextStyle(
                                  fontSize: responsive.fontSize18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.p12),
                          Expanded(
                            child: Text(
                              course.name,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFF2B7FFF),
                              size: responsive.iconMedium,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: responsive.p16),
          ],
        ),
      ),
    );
  }
}
