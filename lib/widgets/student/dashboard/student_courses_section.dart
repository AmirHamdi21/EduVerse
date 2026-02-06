import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../common/animated_progress_bar.dart';
import '../courses/course_model.dart';

class StudentCoursesSection extends StatefulWidget {
  const StudentCoursesSection({super.key});

  @override
  State<StudentCoursesSection> createState() => _StudentCoursesSectionState();
}

class _StudentCoursesSectionState extends State<StudentCoursesSection>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<CourseModel> _courses;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _startStaggeredAnimations();
  }

  void _initCourses(AppLocalizations l10n) {
    _courses = [
      CourseModel(
        title: l10n.introductionToAI,
        instructor: l10n.drSarahFarley,
        progress: 0.68,
        nextEvent: 'Lecture',
        eventDate: 'Nov 8',
        iconBackgroundColor: const Color(0xFF155CFB),
        courseIcon: Icons.psychology_outlined,
        modules: [
          CourseModule(
            title: 'Introduction to AI',
            description: 'Fundamentals of Artificial Intelligence',
            status: ModuleStatus.completed,
            contents: [
              ModuleContent(type: 'video'),
              ModuleContent(type: 'pdf'),
            ],
          ),
          CourseModule(
            title: 'Machine Learning Basics',
            description: 'Understanding ML concepts',
            status: ModuleStatus.inProgress,
            contents: [
              ModuleContent(type: 'video'),
              ModuleContent(type: 'slides'),
            ],
          ),
        ],
      ),
      CourseModel(
        title: l10n.dataStructures,
        instructor: l10n.drMarkGoldberg,
        progress: 0.45,
        nextEvent: 'Lab',
        eventDate: 'Nov 9',
        iconBackgroundColor: const Color(0xFF10B981),
        courseIcon: Icons.account_tree_outlined,
        modules: [
          CourseModule(
            title: 'Arrays and Linked Lists',
            description: 'Linear data structures',
            status: ModuleStatus.completed,
            contents: [
              ModuleContent(type: 'video'),
              ModuleContent(type: 'pdf'),
            ],
          ),
          CourseModule(
            title: 'Trees and Graphs',
            description: 'Non-linear data structures',
            status: ModuleStatus.inProgress,
            contents: [
              ModuleContent(type: 'video'),
            ],
          ),
        ],
      ),
      CourseModel(
        title: l10n.calculusII,
        instructor: l10n.drJessicaPeterson,
        progress: 0.72,
        nextEvent: 'Assignment',
        eventDate: 'Nov 10',
        iconBackgroundColor: const Color(0xFFF59E0B),
        courseIcon: Icons.functions_outlined,
        modules: [
          CourseModule(
            title: 'Integration Techniques',
            description: 'Advanced integration methods',
            status: ModuleStatus.completed,
            contents: [
              ModuleContent(type: 'video'),
              ModuleContent(type: 'pdf'),
            ],
          ),
          CourseModule(
            title: 'Series and Sequences',
            description: 'Infinite series analysis',
            status: ModuleStatus.inProgress,
            contents: [
              ModuleContent(type: 'video'),
              ModuleContent(type: 'slides'),
            ],
          ),
        ],
      ),
    ];
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToCourseDetails(BuildContext context, CourseModel course, {int initialTab = 0}) {
    context.push('/course-details', extra: {
      'course': course,
      'initialTab': initialTab,
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        
        // Initialize courses with localized strings
        _initCourses(l10n);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.myCoursesSection,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101727),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.push("/courses");
                  },
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      color: const Color(0xFF155CFB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_courses.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index < _courses.length - 1 ? 12 : 0),
                child: _buildAnimatedCourseCard(
                  _cardControllers[index],
                  course: _courses[index],
                  isDark: isDark,
                  l10n: l10n,
                  onContinue: () => _navigateToCourseDetails(context, _courses[index]),
                  onMaterials: () => _navigateToCourseDetails(context, _courses[index], initialTab: 0),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCourseCard(
    AnimationController controller, {
    required CourseModel course,
    required bool isDark,
    required AppLocalizations l10n,
    required VoidCallback onContinue,
    required VoidCallback onMaterials,
  }) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: _buildCourseCard(
            course: course,
            isDark: isDark,
            l10n: l10n,
            onContinue: onContinue,
            onMaterials: onMaterials,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required CourseModel course,
    required bool isDark,
    required AppLocalizations l10n,
    required VoidCallback onContinue,
    required VoidCallback onMaterials,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF16213E) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E7EB),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    course.iconBackgroundColor.withOpacity(0.8),
                    course.iconBackgroundColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(course.courseIcon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101727),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF495565),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.instructor,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF495565),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.materials}: ${course.modules?.length ?? 0}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF495565),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(course.progress * 100).toInt()}% ${l10n.complete}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF495565),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CompactAnimatedProgressBar(
              value: course.progress,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE5E7EB),
              valueColor: course.iconBackgroundColor,
              minHeight: 6,
              duration: const Duration(milliseconds: 1500),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF155CFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(l10n.continueButton),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onMaterials,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? Colors.transparent : Colors.white,
                  foregroundColor: const Color(0xFF155CFB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: Color(0xFF155CFB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  l10n.materials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
