import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'course_tab_content.dart';
import 'labs_tab_content.dart';
import 'assignments_tab_content.dart';
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

class _CourseTabsState extends State<CourseTabs>
    with TickerProviderStateMixin {
  final List<String> tabs = ['🧠', '🧪', '📝', '📈', '💬'];
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF364153);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab buttons with horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
                child: _buildTabButton(
                  index,
                  tabs[index],
                  bgColor,
                  textColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
      );
    } else if (widget.selectedIndex == 2) {
      // Assignments tab
      return AssignmentsTabContent(
        isDark: widget.isDark,
      );
    } else if (widget.selectedIndex == 3) {
      // Statistics tab
      return StatisticsTabContent(
        isDark: widget.isDark,
      );
    } else if (widget.selectedIndex == 4) {
      // Discussion tab
      return DiscussionTabContent(
        isDark: widget.isDark,
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

  Widget _buildTabButton(
    int index,
    String emoji,
    Color bgColor,
    Color textColor,
  ) {
    final isSelected = index == widget.selectedIndex;

    return AnimatedContainer(
      height: 36,
      width: 68,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF155DFC) : bgColor,
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF155DFC).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTabChanged(index),
          borderRadius: BorderRadius.circular(14),
          splashColor: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : const Color(0xFF155DFC).withValues(alpha: 0.1),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : textColor,
              ),
              child: Text(emoji),
            ),
          ),
        ),
      ),
    );
  }
}
