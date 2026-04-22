import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/language/language_cubit.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/student/dashboard/student_app_bar.dart';
import '../../widgets/student/dashboard/student_stats_section.dart';
import '../../widgets/student/dashboard/student_quick_access_grid.dart';
import '../../widgets/student/dashboard/student_courses_section.dart';
import '../../widgets/student/dashboard/student_todo_section.dart';
import '../../widgets/student/dashboard/student_performance_section.dart';
import '../../widgets/student/dashboard/student_ai_assistant_card.dart';
import '../../widgets/student/dashboard/student_drawer.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: const StudentDrawer(),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEEF5FE),
                          Colors.white,
                          Color(0xFFFAF5FE),
                        ],
                      ),
                    ),
              child: CustomScrollView(
                slivers: [
                  const StudentAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const StudentStatsSection(),
                        const SizedBox(height: 24),
                        const StudentQuickAccessGrid(),
                        const SizedBox(height: 24),
                        const StudentCoursesSection(),
                        const SizedBox(height: 24),
                        const StudentTodoSection(),
                        const SizedBox(height: 24),
                        const StudentPerformanceSection(),
                        const SizedBox(height: 24),
                        const StudentAiAssistantCard(),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
