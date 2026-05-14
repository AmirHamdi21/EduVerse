import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/courses/courses_bloc.dart';
import '../../bloc/courses/courses_event.dart';
import '../../bloc/labs/labs_cubit.dart';
import '../../bloc/student_registration/student_registration_cubit.dart';
import '../../bloc/student_registration/student_registration_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/student_courses_theme.dart';
import '../../features/walkthrough/student_walkthrough_registry.dart';
import '../../features/walkthrough/walkthrough_target.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/registration/registration_available_course_model.dart';
import '../../models/registration/registration_available_section_model.dart';
import '../../utils/navigation/safe_back.dart';
import '../../widgets/student/registration/available_course_card.dart';
import '../../widgets/student/registration/registered_course_card.dart';
import '../../widgets/student/registration/registration_empty_state.dart';
import '../../widgets/student/registration/registration_filter_bar.dart';
import '../../widgets/student/registration/registration_header.dart';
import '../../widgets/student/registration/registration_loading_view.dart';
import '../../widgets/student/registration/registration_stats_row.dart';
import '../../widgets/student/registration/section_selection_sheet.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<StudentRegistrationCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final bool isDark = themeState.isDark;
        return StudentWalkthroughRouteMarker(
          segmentId: StudentWalkthroughIds.registration,
          child: Scaffold(
            backgroundColor: StudentCoursesTheme.scaffoldBackground(isDark),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => safeBack(context, '/dashboard'),
                icon: Icon(iosBackIcon(context)),
              ),
              title: Text(AppLocalizations.of(context).registration),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body:
                BlocConsumer<
                  StudentRegistrationCubit,
                  StudentRegistrationState
                >(
                  listenWhen: (previous, current) =>
                      previous.successMessage != current.successMessage ||
                      previous.errorMessage != current.errorMessage,
                  listener: (context, state) {
                    if (state.successMessage != null &&
                        state.successMessage!.trim().isNotEmpty) {
                      _showMessage(
                        context,
                        state.successMessage!,
                        const Color(0xFF047857),
                      );
                      _refreshDependentFeatures(context);
                      context.read<StudentRegistrationCubit>().clearMessages();
                    }

                    if (state.errorMessage != null &&
                        state.errorMessage!.trim().isNotEmpty) {
                      _showMessage(
                        context,
                        state.errorMessage!,
                        const Color(0xFFB42318),
                      );
                      context.read<StudentRegistrationCubit>().clearMessages();
                    }
                  },
                  builder: (context, state) {
                    if (state.isInitialLoading) {
                      return RegistrationLoadingView(isDark: isDark);
                    }

                    final l10n = AppLocalizations.of(context);
                    final filtered = state.filteredAvailableCourses;

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<StudentRegistrationCubit>().refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: WalkthroughTarget(
                                id: StudentWalkthroughIds.registrationHeader,
                                child: RegistrationHeader(
                                  period: state.currentPeriod,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: WalkthroughTarget(
                                id: StudentWalkthroughIds.registrationStats,
                                child: RegistrationStatsRow(
                                  stats: state.stats,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: WalkthroughTarget(
                                id: StudentWalkthroughIds.registrationFilters,
                                child: RegistrationFilterBar(
                                  searchQuery: state.searchQuery,
                                  departmentOptions: state.departmentOptions,
                                  levelOptions: state.levelOptions,
                                  selectedDepartment: state.selectedDepartment,
                                  selectedLevel: state.selectedLevel,
                                  isDark: isDark,
                                  onSearchChanged: (value) => context
                                      .read<StudentRegistrationCubit>()
                                      .setSearchQuery(value),
                                  onDepartmentChanged: (value) => context
                                      .read<StudentRegistrationCubit>()
                                      .setDepartment(value),
                                  onLevelChanged: (value) => context
                                      .read<StudentRegistrationCubit>()
                                      .setLevel(value),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                l10n.availableCourses,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF101828),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (filtered.isEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: WalkthroughTarget(
                                  id: StudentWalkthroughIds.registrationCourses,
                                  child: RegistrationEmptyState(
                                    icon: Icons.auto_stories_outlined,
                                    title: l10n.noAvailableCourses,
                                    subtitle: l10n.tryAdjustingFilters,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: WalkthroughTarget(
                                  id: StudentWalkthroughIds.registrationCourses,
                                  child: Column(
                                    children: [
                                      for (final course in filtered)
                                        AvailableCourseCard(
                                          course: course,
                                          isDark: isDark,
                                          isSubmitting:
                                              state.isEnrolling &&
                                              state.selectedCourseId ==
                                                  course.id,
                                          onEnrollPressed: () =>
                                              _onEnrollPressed(context, course),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                l10n.myRegisteredCourses,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF101828),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (state.enrolledCourses.isEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                24,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: RegistrationEmptyState(
                                  icon: Icons.checklist_rtl_outlined,
                                  title: l10n.noRegisteredCourses,
                                  subtitle: l10n.browseCourses,
                                  isDark: isDark,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                24,
                              ),
                              sliver: SliverList.builder(
                                itemCount: state.enrolledCourses.length,
                                itemBuilder: (context, index) {
                                  final enrollment =
                                      state.enrolledCourses[index];
                                  return RegisteredCourseCard(
                                    enrollment: enrollment,
                                    isDark: isDark,
                                    isDropping:
                                        state.isDropping &&
                                        state.activeDropEnrollmentId ==
                                            enrollment.id,
                                    onDropPressed: () {
                                      context
                                          .read<StudentRegistrationCubit>()
                                          .dropEnrollment(enrollment.id);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }

  Future<void> _onEnrollPressed(
    BuildContext context,
    RegistrationAvailableCourseModel course,
  ) async {
    final cubit = context.read<StudentRegistrationCubit>();
    if (course.sections.isEmpty) {
      _showMessage(
        context,
        AppLocalizations.of(context).selectSection,
        const Color(0xFFB42318),
      );
      return;
    }

    cubit.selectCourse(course.id);

    if (course.sections.length == 1) {
      final section = course.sections.first;
      if (section.isFull) {
        _showMessage(
          context,
          AppLocalizations.of(context).registrationClosed,
          const Color(0xFFB42318),
        );
        return;
      }
      final bool shouldProceed = await _showSingleSectionConfirm(
        context,
        course: course,
        section: section,
      );
      if (!shouldProceed || !mounted) {
        return;
      }
      cubit.selectSection(section.id);
      await cubit.enrollSelectedSection();
      return;
    }

    cubit.selectSection(course.primarySection?.id);
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocBuilder<StudentRegistrationCubit, StudentRegistrationState>(
          builder: (_, state) {
            return SectionSelectionSheet(
              course: course,
              selectedSectionId: state.selectedSectionId,
              isSubmitting: state.isEnrolling,
              onSectionSelected: (sectionId) => cubit.selectSection(sectionId),
              onConfirm: () async {
                final bool success = await cubit.enrollSelectedSection();
                if (!sheetContext.mounted) return;
                if (success && Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _showSingleSectionConfirm(
    BuildContext context, {
    required RegistrationAvailableCourseModel course,
    required RegistrationAvailableSectionModel section,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmEnrollment),
          content: Text(
            '${course.code} • ${course.name}\nSection ${section.sectionNumber}\n${section.semesterName}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  void _refreshDependentFeatures(BuildContext context) {
    try {
      context.read<CoursesBloc>().add(const CoursesRefreshed());
    } catch (_) {
      // Keep registration flow resilient if CoursesBloc is not mounted.
    }

    try {
      context.read<LabsCubit>().loadEnrolledCourses();
    } catch (_) {
      // Keep registration flow resilient if LabsCubit is not mounted.
    }
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
