import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../screens/instructor/create_assignment_screen.dart';
import '../../../widgets/instructor/assignments/assignment_card.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import 'ta_assignment_submissions_screen.dart';

class TAAssignmentsScreen extends StatefulWidget {
  const TAAssignmentsScreen({super.key});

  @override
  State<TAAssignmentsScreen> createState() => _TAAssignmentsScreenState();
}

class _TAAssignmentsScreenState extends State<TAAssignmentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      await cubit.fetchTACourses();
    }

    if (!mounted) {
      return;
    }

    _syncSelectedCourse(context.read<TACoursesCubit>().state);
  }

  void _syncSelectedCourse(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      return;
    }

    final courses = status.data;
    if (courses.isEmpty) {
      return;
    }

    final hasSelected =
        _selectedCourseId != null &&
        courses.any((course) => course.courseId == _selectedCourseId);
    final nextCourseId = hasSelected
        ? _selectedCourseId
        : courses.first.courseId;

    if (nextCourseId == null || nextCourseId == _selectedCourseId) {
      if (state.assignmentsData is TASubTabInitial<List<AssignmentModel>>) {
        context.read<TACoursesCubit>().fetchCourseAssignments(nextCourseId!);
      }
      return;
    }

    setState(() => _selectedCourseId = nextCourseId);
    context.read<TACoursesCubit>().fetchCourseAssignments(nextCourseId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocConsumer<TACoursesCubit, TACoursesState>(
          listener: (context, state) {
            _syncSelectedCourse(state);
          },
          builder: (context, state) {
            final courses = _coursesFromState(state);

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: TAColors.scaffoldColor(isDark),
              drawer: TADrawer(currentRoute: '/ta/assignments', isDark: isDark),
              floatingActionButton: _selectedCourseId == null
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => _openAssignmentEditor(context),
                      backgroundColor: TAColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Assignment'),
                    ),
              body: SafeArea(
                child: RefreshIndicator(
                  color: TAColors.primary,
                  onRefresh: () async {
                    final cubit = context.read<TACoursesCubit>();
                    await cubit.fetchTACourses();
                    if (!mounted) {
                      return;
                    }
                    final courseId = _selectedCourseId;
                    if (courseId != null) {
                      await cubit.fetchCourseAssignments(courseId);
                    }
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      _buildAppBar(isDark),
                      SliverToBoxAdapter(
                        child: _buildHeaderCard(isDark, state, courses),
                      ),
                      _buildAssignmentsBody(isDark, state, courses),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        'Assignments',
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    bool isDark,
    TACoursesState state,
    List<TeachingCourseModel> courses,
  ) {
    TeachingCourseModel? selectedCourse;
    for (final course in courses) {
      if (course.courseId == _selectedCourseId) {
        selectedCourse = course;
        break;
      }
    }

    final assignmentsState = state.assignmentsData;
    final assignmentCount =
        assignmentsState is TASubTabLoaded<List<AssignmentModel>>
        ? assignmentsState.data.length
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Manage assignments by course',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create, edit, archive, and review submissions from one place.',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue:
                  courses.any((course) => course.courseId == _selectedCourseId)
                  ? _selectedCourseId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Assigned course',
                border: OutlineInputBorder(),
              ),
              items: courses
                  .map(
                    (course) => DropdownMenuItem<int>(
                      value: course.courseId,
                      child: Text(
                        '${course.course.code} - ${course.course.name} • Section ${course.section.sectionNumber}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: courses.isEmpty
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedCourseId = value);
                      context.read<TACoursesCubit>().fetchCourseAssignments(
                        value,
                      );
                    },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                _summaryChip(
                  isDark,
                  icon: Icons.assignment_rounded,
                  label: '$assignmentCount assignment(s)',
                ),
                if (selectedCourse != null)
                  _summaryChip(
                    isDark,
                    icon: Icons.school_rounded,
                    label: selectedCourse.course.courseCode,
                  ),
                if (selectedCourse != null)
                  ActionChip(
                    avatar: const Icon(Icons.grading_rounded, size: 18),
                    label: const Text('Open grading center'),
                    onPressed: () => context.push(
                      '/ta/grading?courseId=${selectedCourse!.courseId}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(
    bool isDark, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: TAColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsBody(
    bool isDark,
    TACoursesState state,
    List<TeachingCourseModel> courses,
  ) {
    final coursesStatus = state.coursesStatus;
    if (coursesStatus is TASubTabLoading<List<TeachingCourseModel>> &&
        courses.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (coursesStatus is TASubTabError<List<TeachingCourseModel>>) {
      return SliverFillRemaining(
        child: _CenteredState(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load assigned courses',
          message: coursesStatus.message,
          actionLabel: 'Retry',
          onAction: () => context.read<TACoursesCubit>().fetchTACourses(),
        ),
      );
    }

    if (courses.isEmpty) {
      return const SliverFillRemaining(
        child: _CenteredState(
          icon: Icons.school_outlined,
          title: 'No assigned courses',
          message:
              'Assignments will appear here once you are assigned to a course.',
        ),
      );
    }

    final assignmentsState = state.assignmentsData;
    if (assignmentsState is TASubTabLoading<List<AssignmentModel>>) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (assignmentsState is TASubTabError<List<AssignmentModel>>) {
      return SliverFillRemaining(
        child: _CenteredState(
          icon: Icons.assignment_late_outlined,
          title: 'Failed to load assignments',
          message: assignmentsState.message,
          actionLabel: 'Retry',
          onAction: () {
            final courseId = _selectedCourseId;
            if (courseId != null) {
              context.read<TACoursesCubit>().fetchCourseAssignments(courseId);
            }
          },
        ),
      );
    }

    final assignments =
        assignmentsState is TASubTabLoaded<List<AssignmentModel>>
        ? assignmentsState.data
        : const <AssignmentModel>[];

    if (assignments.isEmpty) {
      return SliverFillRemaining(
        child: _CenteredState(
          icon: Icons.assignment_outlined,
          title: 'No assignments yet',
          message:
              'Create the first assignment for the selected course from the button below.',
          actionLabel: 'Create assignment',
          onAction: _selectedCourseId == null
              ? null
              : () => _openAssignmentEditor(context),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return AssignmentCard(
            assignment: assignment,
            onViewSubmissions: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TAAssignmentSubmissionsScreen(assignment: assignment),
                ),
              );
            },
            onEdit: () =>
                _openAssignmentEditor(context, assignment: assignment),
            onDelete: () => _confirmDelete(context, assignment),
            onStatusChange: (status) async {
              final courseId = _selectedCourseId;
              if (courseId == null) {
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              final message = await context.read<TACoursesCubit>().updateAssignmentStatus(
                courseId,
                assignment.assignmentId,
                status,
              );
              if (!mounted || message == null) {
                return;
              }
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAssignmentEditor(
    BuildContext context, {
    AssignmentModel? assignment,
  }) async {
    final courseId = _selectedCourseId;
    if (courseId == null) {
      return;
    }

    final cubit = context.read<TACoursesCubit>();
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateAssignmentScreen(
          assignment: assignment,
          assignmentId: assignment?.assignmentId,
          preferredCourseId: courseId,
        ),
      ),
    );

    if (result == true && mounted) {
      await cubit.fetchCourseAssignments(courseId);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AssignmentModel assignment,
  ) async {
    final courseId = _selectedCourseId;
    if (courseId == null) {
      return;
    }
    final cubit = context.read<TACoursesCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text(
            'Delete "${assignment.title}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await cubit.deleteAssignment(courseId, assignment.assignmentId);
    }
  }

  List<TeachingCourseModel> _coursesFromState(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      return status.data;
    }
    return const <TeachingCourseModel>[];
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
