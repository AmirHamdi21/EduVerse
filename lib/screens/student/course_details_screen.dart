import 'package:edu_verse/widgets/student/courses/courses_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../widgets/student/courses/course_model.dart';
import '../../widgets/student/course_details/course_instructor_info.dart';
import '../../widgets/student/course_details/course_action_buttons.dart';
import '../../widgets/student/course_details/course_completion_bar.dart';
import '../../widgets/student/course_details/course_tabs.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFFAFAFA);
        final surfaceColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF101828);
        final secondaryTextColor = isDark
            ? const Color(0xFFB0B0B0)
            : const Color(0xFF4A5565);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Stack(
              children: [
                // // Animated background blobs
                // Positioned(
                //   top: -50,
                //   left: 50,
                //   child: Container(
                //     width: 280,
                //     height: 280,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF51a2ff).withOpacity(0.1),
                //       shape: BoxShape.circle,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   top: 150,
                //   left: 80,
                //   child: Container(
                //     width: 260,
                //     height: 260,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFFc27aff).withOpacity(0.08),
                //       shape: BoxShape.circle,
                //     ),
                //   ),
                // ),
                // Main content
                CustomScrollView(
                  slivers: [
                    // Header
                    const CoursesAppBar(),
                    // Course title and instructor
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arimo',
                              ),
                            ),
                            const SizedBox(height: 16),
                            CourseInstructorInfo(
                              instructor: widget.course.instructor,
                              instructorImage: widget.course.instructorImage,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action buttons
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CourseActionButtons(
                          isDark: isDark,
                          primaryButtonLabel: widget.course.primaryButtonLabel,
                        ),
                      ),
                    ),
                    // Course completion bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: CourseCompletionBar(
                          progress: widget.course.progress,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    // Tabs and content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CourseTabs(
                          selectedIndex: _selectedTabIndex,
                          onTabChanged: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          isDark: isDark,
                          course: widget.course,
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating action button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF155DFC).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(50),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(Color bgColor, IconData icon, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: textColor),
          ),
        ),
      ),
    );
  }
}
