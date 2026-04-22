import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'course_tab_content.dart';
import 'labs_tab_content.dart';
import 'assignments_tab_content.dart';
import 'announcements_tab_content.dart';
import 'prerequisites_tab_content.dart';
import 'statistics_tab_content.dart';
import 'discussion_tab_content.dart';

class CourseTabs extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final bool isDark;
  final CourseModel course;

  const CourseTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.isDark,
    required this.course,
  });

  @override
  State<CourseTabs> createState() => _CourseTabsState();
}

class _CourseTabsState extends State<CourseTabs> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> tabs = [
    {'icon': Icons.video_library_outlined, 'label': 'Lectures'},
    {'icon': Icons.science_outlined, 'label': 'Labs'},
    {'icon': Icons.assignment_outlined, 'label': 'Assignments'},
    {'icon': Icons.campaign_outlined, 'label': 'Announcements'},
    {'icon': Icons.rule_folder_outlined, 'label': 'Prerequisites'},
    {'icon': Icons.analytics_outlined, 'label': 'Statistics'},
    {'icon': Icons.forum_outlined, 'label': 'Discussion'},
  ];
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );

    _contentController.forward();
  }

  @override
  void didUpdateWidget(CourseTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _contentController.reset();
      _contentController.forward();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Course Content',
          style: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF101828),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Tab buttons with horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : 10,
                ),
                child: _buildTabButton(index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Tab content with animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    if (widget.selectedIndex == 0) {
      // Lectures tab
      return CourseTabContent(
        selectedIndex: widget.selectedIndex,
        isDark: widget.isDark,
        course: widget.course,
      );
    } else if (widget.selectedIndex == 1) {
      // Labs tab
      return LabsTabContent(
        isDark: widget.isDark,
        courseId: widget.course.courseId,
      );
    } else if (widget.selectedIndex == 2) {
      // Assignments tab
      return AssignmentsTabContent(
        isDark: widget.isDark,
        courseId: widget.course.courseId,
      );
    } else if (widget.selectedIndex == 3) {
      // Announcements tab
      return AnnouncementsTabContent(
        isDark: widget.isDark,
        courseId: widget.course.courseId,
      );
    } else if (widget.selectedIndex == 4) {
      // Prerequisites tab
      return PrerequisitesTabContent(isDark: widget.isDark);
    } else if (widget.selectedIndex == 5) {
      // Statistics tab
      return StatisticsTabContent(isDark: widget.isDark);
    } else if (widget.selectedIndex == 6) {
      // Discussion tab
      return DiscussionTabContent(
        isDark: widget.isDark,
        courseId: widget.course.courseId,
      );
    } else {
      // Placeholder for other tabs
      return Center(
        child: Text(
          'Tab ${widget.selectedIndex + 1} content coming soon',
          style: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF4A5565),
            fontSize: 14,
            fontFamily: 'Arimo',
          ),
        ),
      );
    }
  }

  Widget _buildTabButton(int index) {
    final isSelected = index == widget.selectedIndex;
    final tabData = tabs[index];
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              )
            : null,
        color: isSelected ? null : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : (widget.isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTabChanged(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tabData['icon'],
                  color: isSelected
                      ? Colors.white
                      : (widget.isDark
                            ? Colors.white54
                            : const Color(0xFF667085)),
                  size: 20,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    tabData['label'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
