import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';

class CourseSelector extends StatefulWidget {
  final List<Course> courses;
  final Course selectedCourse;
  final Function(Course) onCourseChanged;
  final bool isDark;

  const CourseSelector({
    super.key,
    required this.courses,
    required this.selectedCourse,
    required this.onCourseChanged,
    required this.isDark,
  });

  @override
  State<CourseSelector> createState() => _CourseSelectorState();
}

class _CourseSelectorState extends State<CourseSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _dropdownController;
  late Animation<double> _dropdownAnimation;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dropdownAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dropdownController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _dropdownController.reverse();
    } else {
      _dropdownController.forward();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arimo',
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.selectedCourse.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(_dropdownAnimation),
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isDropdownOpen)
          ScaleTransition(
            scale: _dropdownAnimation,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF3D3D54)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark
                        ? const Color(0xFF4D4D64)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: List.generate(widget.courses.length, (index) {
                    final course = widget.courses[index];
                    final isLast = index == widget.courses.length - 1;

                    return GestureDetector(
                      onTap: () {
                        widget.onCourseChanged(course);
                        _toggleDropdown();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: !isLast
                              ? Border(
                                  bottom: BorderSide(
                                    color: widget.isDark
                                        ? const Color(0xFF4D4D64)
                                        : const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              course.name,
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF101828),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Arimo',
                              ),
                            ),
                            const Spacer(),
                            if (course.id == widget.selectedCourse.id)
                              const Icon(
                                Icons.check,
                                color: Color(0xFF2B7FFF),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
