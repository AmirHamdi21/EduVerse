import 'package:edu_verse/widgets/student/course_details/course_details_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../widgets/student/courses/course_model.dart';
import '../../widgets/student/course_details/course_tabs.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late AnimationController _headerAnimationController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = true);
        _headerAnimationController.forward();
      } else if (_scrollController.offset <= 100 && _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = false);
        _headerAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF5F7FA);

        return Scaffold(
          backgroundColor: bgColor,

          body: Stack(
            children: [
              // Main scrollable content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Hero header with gradient
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                              : [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CourseDetailsHeader(
                                title: widget.course.title,
                                isDark: isDark,
                                onBackPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 20),
                              // Stats cards row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.assessment_outlined,
                                      value:
                                          '${(widget.course.progress * 100).toInt()}%',
                                      label: 'Progress',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.calendar_today_outlined,
                                      value: widget.course.eventDate,
                                      label: 'Next Event',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.schedule_outlined,
                                      value: '12h',
                                      label: 'Duration',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Content card
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instructor info card
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2D2D44)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF2B7FFF),
                                            Color(0xFF155DFC),
                                          ],
                                        ),
                                      ),
                                      child:
                                          widget.course.instructorImage != null
                                          ? ClipOval(
                                              child: Image.network(
                                                widget.course.instructorImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.course.instructor,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF101828),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Course Instructor',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white54
                                                  : const Color(0xFF667085),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.message_outlined,
                                        color: const Color(0xFF155DFC),
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildActionButton(
                                      label: widget.course.primaryButtonLabel,
                                      icon: Icons.play_circle_outline,
                                      isPrimary: true,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      label: 'Chat',
                                      icon: Icons.chat_bubble_outline,
                                      isPrimary: false,
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Progress section
                              _buildProgressSection(isDark),
                              const SizedBox(height: 24),
                              // Tabs
                              CourseTabs(
                                selectedIndex: _selectedTabIndex,
                                onTabChanged: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                                isDark: isDark,
                                course: widget.course,
                              ),
                              // const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // // Floating action button
              // Positioned(
              //   bottom: 20,
              //   right: 20,
              //   child: FloatingActionButton(
              //     onPressed: () {},
              //     backgroundColor: const Color(0xFF155DFC),
              //     elevation: 8,
              //     child: const Icon(Icons.add, color: Colors.white, size: 28),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              )
            : null,
        color: isPrimary
            ? null
            : (context.read<ThemeBloc>().state.isDark
                  ? const Color(0xFF2D2D44)
                  : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFF155DFC), width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF155DFC).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF155DFC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF155DFC),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    final progress = widget.course.progress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D3D54)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.course.nextEvent,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF667085),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
