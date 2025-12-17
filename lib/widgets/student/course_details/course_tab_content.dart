import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'course_module_card.dart';

class CourseTabContent extends StatefulWidget {
  final int selectedIndex;
  final bool isDark;
  final CourseModel course;

  const CourseTabContent({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.course,
  });

  @override
  State<CourseTabContent> createState() => _CourseTabContentState();
}

class _CourseTabContentState extends State<CourseTabContent> {
  late List<CourseModule> modules;
  late List<bool> expandedStates;

  @override
  void initState() {
    super.initState();
    _initializeModules();
  }

  void _initializeModules() {
    modules = [
      CourseModule(
        title: 'Week 1: Foundations of AI',
        description: 'An introduction to the history of artificial intelligence, key concepts, and philosophical debates surrounding AI.',
        status: ModuleStatus.completed,
        contents: [
          ModuleContent(type: 'video'),
          ModuleContent(type: 'pdf'),
          ModuleContent(type: 'slides'),
        ],
      ),
      CourseModule(
        title: 'Week 2: Machine Learning Basics',
        description: 'Learn the fundamentals of machine learning including supervised and unsupervised learning.',
        status: ModuleStatus.inProgress,
        contents: [
          ModuleContent(type: 'video'),
          ModuleContent(type: 'pdf'),
          ModuleContent(type: 'slides'),
        ],
      ),
      CourseModule(
        title: 'Week 3: Neural Networks',
        description: 'Deep dive into neural network architecture, training, and optimization techniques.',
        status: ModuleStatus.notStarted,
        contents: [
          ModuleContent(type: 'video'),
          ModuleContent(type: 'pdf'),
        ],
      ),
      CourseModule(
        title: 'Week 4: Deep Learning Fundamentals',
        description: 'Explore deep learning frameworks and practical applications in real-world scenarios.',
        status: ModuleStatus.notStarted,
        contents: [
          ModuleContent(type: 'video'),
          ModuleContent(type: 'slides'),
        ],
      ),
    ];
    expandedStates = List.filled(modules.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);

    return Column(
      children: List.generate(
        modules.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == modules.length - 1 ? 0 : 16),
          child: CourseModuleCard(
            module: modules[index],
            isExpanded: expandedStates[index],
            onToggleExpand: () {
              setState(() {
                expandedStates[index] = !expandedStates[index];
              });
            },
            isDark: widget.isDark,
          ),
        ),
      ),
    );
  }
}
