import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_course_management_models.dart';
import '../../../services/api/admin_course_management_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

enum _CourseSubTab { courses, staff, schedule, exams }

class AdminCourseManagementScreen extends StatefulWidget {
  final AdminCourseManagementService? courseService;
  final bool openAddOnStart;
  final int? openEditCourseId;

  const AdminCourseManagementScreen({
    super.key,
    this.courseService,
    this.openAddOnStart = false,
    this.openEditCourseId,
  });

  @override
  State<AdminCourseManagementScreen> createState() =>
      _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState
    extends State<AdminCourseManagementScreen> {
  static const List<String> _levelOptions = <String>[
    'FRESHMAN',
    'SOPHOMORE',
    'JUNIOR',
    'SENIOR',
    'GRADUATE',
  ];

  static const List<String> _statusOptions = <String>[
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED',
  ];

  static const List<String> _weekdayOptions = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  CoreApiClient? _coreApiClient;
  late final AdminCourseManagementService _courseService;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _didTriggerInitialModal = false;

  _CourseSubTab _activeSubTab = _CourseSubTab.courses;
  String _departmentFilter = 'all';
  String _statusFilter = 'all';

  List<AdminManagedCourse> _courses = const <AdminManagedCourse>[];
  List<AdminSemesterOption> _semesters = const <AdminSemesterOption>[];
  List<AdminStaffOption> _instructors = const <AdminStaffOption>[];
  List<AdminStaffOption> _tas = const <AdminStaffOption>[];
  List<AdminDepartmentOption> _departments = const <AdminDepartmentOption>[];

  @override
  void initState() {
    super.initState();

    if (widget.courseService != null) {
      _courseService = widget.courseService!;
    } else {
      _coreApiClient = CoreApiClient();
      _courseService = AdminCourseManagementService(
        coreApiClient: _coreApiClient!,
      );
    }

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadBootstrap();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _coreApiClient?.dio.close(force: true);
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      _loadCoursesOnly(silent: true);
    });
  }

  Future<void> _loadBootstrap({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      if (silent) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    final coursesResult = await _courseService.getCourses(
      search: _searchController.text,
      status: _statusFilter == 'all' ? null : _statusFilter,
    );
    final semestersResult = await _courseService.getSemesters();
    final instructorsResult = await _courseService.getStaffOptions(
      role: 'instructor',
    );
    final tasResult = await _courseService.getStaffOptions(
      role: 'teaching_assistant',
    );
    final departmentsResult = await _courseService.getDepartments();

    if (!mounted) {
      return;
    }

    String? nextError;
    if (coursesResult.isFailure) {
      nextError = coursesResult.error?.message;
    }
    if (nextError == null && semestersResult.isFailure) {
      nextError = semestersResult.error?.message;
    }
    if (nextError == null && instructorsResult.isFailure) {
      nextError = instructorsResult.error?.message;
    }
    if (nextError == null && tasResult.isFailure) {
      nextError = tasResult.error?.message;
    }
    if (nextError == null && departmentsResult.isFailure) {
      nextError = departmentsResult.error?.message;
    }

    setState(() {
      _isLoading = false;
      _isRefreshing = false;
      _errorMessage = nextError;
      _courses = coursesResult.data ?? const <AdminManagedCourse>[];
      _semesters = semestersResult.data ?? const <AdminSemesterOption>[];
      _instructors = instructorsResult.data ?? const <AdminStaffOption>[];
      _tas = tasResult.data ?? const <AdminStaffOption>[];
      _departments = departmentsResult.data ?? const <AdminDepartmentOption>[];
    });

    _tryOpenInitialModal();
  }

  Future<void> _loadCoursesOnly({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _courseService.getCourses(
      search: _searchController.text,
      status: _statusFilter == 'all' ? null : _statusFilter,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage =
            result.error?.message ?? 'Failed to load courses. Please retry.';
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _isRefreshing = false;
      _errorMessage = null;
      _courses = result.data ?? const <AdminManagedCourse>[];
    });

    _tryOpenInitialModal();
  }

  void _tryOpenInitialModal() {
    if (_didTriggerInitialModal) {
      return;
    }

    final wantsAdd = widget.openAddOnStart;
    final editCourseId = widget.openEditCourseId;
    if (!wantsAdd && editCourseId == null) {
      return;
    }

    _didTriggerInitialModal = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (editCourseId != null) {
        final index = _courses.indexWhere(
          (course) => course.id == editCourseId,
        );
        if (index < 0) {
          _showSnackBar('Course #$editCourseId was not found.', isError: true);
          return;
        }
        await _openCourseFlowModal(l10n, course: _courses[index]);
        return;
      }

      if (wantsAdd) {
        await _openCourseFlowModal(l10n);
      }
    });
  }

  List<String> get _departmentFilters {
    final names =
        _courses
            .map((course) => course.department.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return <String>['all', ...names];
  }

  List<AdminManagedCourse> get _visibleCourses {
    final search = _searchController.text.trim().toLowerCase();

    return _courses.where((course) {
      if (_departmentFilter != 'all' &&
          course.department != _departmentFilter) {
        return false;
      }

      if (_statusFilter != 'all' &&
          course.status.toUpperCase() != _statusFilter.toUpperCase()) {
        return false;
      }

      if (search.isEmpty) {
        return true;
      }

      return course.name.toLowerCase().contains(search) ||
          course.code.toLowerCase().contains(search) ||
          course.instructorName.toLowerCase().contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _loadBootstrap(silent: true),
              color: AdminColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                children: [
                  _buildHeader(isDark, l10n),
                  const SizedBox(height: 16),
                  _buildSubTabSelector(isDark, l10n),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    _buildErrorBanner(isDark, _errorMessage!),
                    const SizedBox(height: 12),
                  ],
                  if (_isLoading && _courses.isEmpty)
                    _buildInitialLoadingState(isDark)
                  else ...[
                    if (_activeSubTab == _CourseSubTab.courses)
                      _buildCoursesTab(isDark, l10n),
                    if (_activeSubTab == _CourseSubTab.staff)
                      _buildStaffTab(isDark, l10n),
                    if (_activeSubTab == _CourseSubTab.schedule)
                      _buildScheduleTab(isDark, l10n),
                    if (_activeSubTab == _CourseSubTab.exams)
                      _buildExamsTab(isDark, l10n),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    final textColor = AdminColors.getTextColor(isDark);
    final subtitleColor = AdminColors.getTextSecondaryColor(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0EA5E9),
            Color(0xFF2563EB),
            Color(0xFFF97316),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => context.pushReplacement('/admin/dashboard'),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.courseManagement,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_courses.length} live courses with website-parity workflows',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(isDark, l10n),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeaderFlowChip(step: '1', label: 'Courses'),
              _HeaderFlowChip(step: '2', label: 'Staff'),
              _HeaderFlowChip(step: '3', label: 'Schedule'),
              _HeaderFlowChip(step: '4', label: 'Exams'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Department-aware controls optimized for mobile operations.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_isRefreshing) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
          if (!isDark) ...[
            const SizedBox(height: 4),
            Text(
              '',
              style: TextStyle(
                color: textColor.withValues(alpha: 0),
                fontSize: 0,
              ),
            ),
            Text(
              '',
              style: TextStyle(
                color: subtitleColor.withValues(alpha: 0),
                fontSize: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark, AppLocalizations l10n) {
    final showMainAction =
        _activeSubTab == _CourseSubTab.courses ||
        _activeSubTab == _CourseSubTab.staff;
    if (!showMainAction) {
      return const SizedBox.shrink();
    }

    final icon = _activeSubTab == _CourseSubTab.courses
        ? Icons.add_rounded
        : Icons.person_add_alt_1_rounded;
    final label = _activeSubTab == _CourseSubTab.courses
        ? l10n.addCourse
        : 'Assign Staff';

    return FilledButton.icon(
      onPressed: () {
        final l10n = AppLocalizations.of(context);
        if (_activeSubTab == _CourseSubTab.courses) {
          _openCourseFlowModal(l10n);
          return;
        }

        if (_visibleCourses.isEmpty) {
          _showSnackBar(
            'No course selected for staff assignment.',
            isError: true,
          );
          return;
        }

        final target = _visibleCourses.first;
        _openCourseFlowModal(
          l10n,
          course: target,
          initialStep: target.sectionId == null ? 2 : 3,
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D4ED8),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubTabSelector(bool isDark, AppLocalizations l10n) {
    final items = <(_CourseSubTab, IconData, String)>[
      (_CourseSubTab.courses, Icons.book_rounded, l10n.courses),
      (_CourseSubTab.staff, Icons.groups_2_rounded, l10n.staff),
      (_CourseSubTab.schedule, Icons.calendar_month_rounded, l10n.schedule),
      (_CourseSubTab.exams, Icons.fact_check_rounded, l10n.exam),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final selected = _activeSubTab == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _activeSubTab = item.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AdminColors.primary
                      : AdminColors.getCardColor(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AdminColors.primary
                        : AdminColors.getCardBorderColor(isDark),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$2,
                      size: 16,
                      color: selected
                          ? Colors.white
                          : AdminColors.getTextSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.$3,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AdminColors.getTextColor(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoursesTab(bool isDark, AppLocalizations l10n) {
    final courses = _visibleCourses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterCard(isDark, l10n),
        const SizedBox(height: 14),
        if (courses.isEmpty)
          _buildEmptyCard(
            isDark,
            title: 'No courses found',
            subtitle: 'Adjust filters or create a new course.',
            icon: Icons.school_outlined,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              int crossAxisCount = 1;
              if (maxWidth >= 1100) {
                crossAxisCount = 3;
              } else if (maxWidth >= 700) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                itemCount: courses.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: maxWidth >= 700 ? 0.95 : 0.88,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _buildCourseCard(course, isDark, l10n);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildStaffTab(bool isDark, AppLocalizations l10n) {
    final courses = _visibleCourses;
    if (courses.isEmpty) {
      return _buildEmptyCard(
        isDark,
        title: 'No courses available',
        subtitle: 'Create courses first, then assign instructors and TAs.',
        icon: Icons.groups_outlined,
      );
    }

    return Column(
      children: courses.map((course) {
        final tasText = course.taNames.isEmpty
            ? 'None'
            : course.taNames.join(', ');
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.getCardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${course.code} - ${course.name}',
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openCourseFlowModal(
                      l10n,
                      course: course,
                      initialStep: course.sectionId == null ? 2 : 3,
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Assign'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(
                isDark,
                icon: Icons.person_rounded,
                label: 'Instructor',
                value: course.instructorName,
              ),
              const SizedBox(height: 6),
              _infoRow(
                isDark,
                icon: Icons.group_rounded,
                label: 'Teaching Assistants',
                value: tasText,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleTab(bool isDark, AppLocalizations l10n) {
    final courses = _visibleCourses;
    if (courses.isEmpty) {
      return _buildEmptyCard(
        isDark,
        title: 'No schedules available',
        subtitle: 'Create a section and schedule in the course flow modal.',
        icon: Icons.schedule_rounded,
      );
    }

    return Column(
      children: courses.map((course) {
        final hasSection = course.sectionId != null;
        final scheduleText = hasSection
            ? '${course.scheduleDay} ${course.startTime} - ${course.endTime}'
            : 'Section not configured yet';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.getCardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${course.code} - ${course.name}',
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openCourseFlowModal(
                      l10n,
                      course: course,
                      initialStep: 2,
                    ),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(
                isDark,
                icon: Icons.class_rounded,
                label: 'Section',
                value: hasSection ? course.sectionNumber : 'Not set',
              ),
              const SizedBox(height: 6),
              _infoRow(
                isDark,
                icon: Icons.access_time_rounded,
                label: 'Schedule',
                value: scheduleText,
              ),
              const SizedBox(height: 6),
              _infoRow(
                isDark,
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: hasSection ? course.location : 'Not set',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExamsTab(bool isDark, AppLocalizations l10n) {
    final courses = _visibleCourses;
    if (courses.isEmpty) {
      return _buildEmptyCard(
        isDark,
        title: 'No exam overview available',
        subtitle: 'Once courses are configured, exam slots can be assigned.',
        icon: Icons.fact_check_outlined,
      );
    }

    return Column(
      children: List<Widget>.generate(courses.length, (index) {
        final course = courses[index];
        final isFinal = index.isEven;
        final badgeColor = isFinal
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);
        final date = DateTime.now().add(Duration(days: 12 + (index * 2)));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.getCardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${course.code} - ${course.name}',
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isFinal ? 'Final' : 'Midterm',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(
                isDark,
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value:
                    '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}',
              ),
              const SizedBox(height: 6),
              _infoRow(
                isDark,
                icon: Icons.room_preferences_rounded,
                label: 'Room',
                value:
                    'Hall ${String.fromCharCode(65 + (index % 4))}-10${index % 10}',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCourseCard(
    AdminManagedCourse course,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 74,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF0EA5E9), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.13,
                    child: Icon(
                      Icons.book_rounded,
                      size: 78,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.book_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      course.code,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _miniStat(
                    isDark,
                    icon: Icons.group_rounded,
                    text: '${course.enrolled}/${course.capacity} enrolled',
                  ),
                  const SizedBox(height: 4),
                  _miniStat(
                    isDark,
                    icon: Icons.person_rounded,
                    text: course.instructorName,
                  ),
                  const SizedBox(height: 4),
                  _miniStat(
                    isDark,
                    icon: Icons.apartment_rounded,
                    text: course.department,
                  ),
                  const Spacer(),
                  Text(
                    'Enrollment ${course.enrollmentPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (course.enrollmentPercent / 100).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AdminColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _iconActionButton(
                        isDark: isDark,
                        icon: Icons.edit_rounded,
                        tooltip: 'Edit Course',
                        onTap: () => _openCourseFlowModal(l10n, course: course),
                      ),
                      const SizedBox(width: 8),
                      _iconActionButton(
                        isDark: isDark,
                        icon: Icons.group_add_rounded,
                        tooltip: 'Assign Staff',
                        onTap: () => _openCourseFlowModal(
                          l10n,
                          course: course,
                          initialStep: course.sectionId == null ? 2 : 3,
                        ),
                      ),
                      const Spacer(),
                      _iconActionButton(
                        isDark: isDark,
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Delete Course',
                        color: AdminColors.error,
                        onTap: () => _openDeleteCourseDialog(l10n, course),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(bool isDark, AppLocalizations l10n) {
    final departments = _departmentFilters;
    final safeDepartment = departments.contains(_departmentFilter)
        ? _departmentFilter
        : 'all';
    final safeStatus =
        <String>['all', ..._statusOptions].contains(_statusFilter)
        ? _statusFilter
        : 'all';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(color: AdminColors.getTextColor(isDark)),
            decoration: InputDecoration(
              hintText: l10n.searchCourses,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _loadCoursesOnly(silent: true);
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(
                    'department-$safeDepartment-${departments.length}',
                  ),
                  initialValue: safeDepartment,
                  decoration: InputDecoration(
                    labelText: l10n.department,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items: departments
                      .map(
                        (department) => DropdownMenuItem<String>(
                          value: department,
                          child: Text(
                            department == 'all'
                                ? 'All Departments'
                                : department,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _departmentFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('status-$safeStatus'),
                  initialValue: safeStatus,
                  decoration: InputDecoration(
                    labelText: l10n.status,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items: <String>['all', ..._statusOptions]
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status == 'all' ? 'All Statuses' : status,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _statusFilter = value);
                    _loadCoursesOnly(silent: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCourseFlowModal(
    AppLocalizations l10n, {
    AdminManagedCourse? course,
    int initialStep = 1,
  }) async {
    final isEditing = course != null;

    final codeController = TextEditingController(text: course?.code ?? '');
    final nameController = TextEditingController(text: course?.name ?? '');
    final creditsController = TextEditingController(
      text: (course?.credits ?? 3).toString(),
    );
    final sectionNumberController = TextEditingController(
      text: course?.sectionNumber.isNotEmpty == true
          ? course!.sectionNumber
          : '01',
    );
    final maxCapacityController = TextEditingController(
      text: (course?.capacity ?? 30).toString(),
    );
    final locationController = TextEditingController(
      text: course?.location.isNotEmpty == true
          ? course!.location
          : 'Room A-101',
    );
    final startTimeController = TextEditingController(
      text: _safeTime(course?.startTime, fallback: '09:00'),
    );
    final endTimeController = TextEditingController(
      text: _safeTime(course?.endTime, fallback: '10:30'),
    );

    var step = initialStep.clamp(1, 3);
    var modalError = '';
    var isSubmitting = false;

    var courseId = course?.id;
    var sectionId = course?.sectionId;

    var selectedDepartmentId = _safeDepartmentId(
      initialValue: course?.departmentId,
      fallback: _departments.isNotEmpty ? _departments.first.id : 0,
    );

    var selectedLevel = _safeOption(
      course?.level,
      _levelOptions,
      fallback: 'FRESHMAN',
    );

    var selectedStatus = _safeOption(
      course?.status,
      _statusOptions,
      fallback: 'ACTIVE',
    );

    var selectedSemesterId = _safeSemesterId(
      initialValue: course?.semesterId,
      fallback: _semesters.isNotEmpty ? _semesters.first.id : 0,
    );

    var selectedDay = _safeOption(
      course?.scheduleDay,
      _weekdayOptions,
      fallback: 'Monday',
    );

    var selectedInstructorId = _safeStaffId(
      initialValue: course?.instructorId,
      available: _instructors,
    );

    var selectedTaIds = (course?.taIds ?? const <int>[])
        .where((id) => _tas.any((item) => item.id == id))
        .toList();

    Future<void> persistStepOne(StateSetter setModalState) async {
      if (codeController.text.trim().isEmpty ||
          nameController.text.trim().isEmpty) {
        setModalState(() => modalError = 'Course code and name are required.');
        return;
      }

      final credits = int.tryParse(creditsController.text.trim()) ?? 0;
      if (credits <= 0) {
        setModalState(() => modalError = 'Credits must be greater than zero.');
        return;
      }

      if (selectedDepartmentId <= 0) {
        setModalState(() => modalError = 'Select a valid department first.');
        return;
      }

      setModalState(() {
        isSubmitting = true;
        modalError = '';
      });

      dynamic createResult;
      dynamic updateResult;

      if (courseId == null) {
        createResult = await _courseService.createCourse(
          code: codeController.text.trim(),
          name: nameController.text.trim(),
          credits: credits,
          departmentId: selectedDepartmentId,
          level: selectedLevel,
          status: selectedStatus,
        );
      } else {
        updateResult = await _courseService.updateCourse(
          courseId: courseId!,
          code: codeController.text.trim(),
          name: nameController.text.trim(),
          credits: credits,
          departmentId: selectedDepartmentId,
          level: selectedLevel,
          status: selectedStatus,
        );
      }

      if (!mounted) {
        return;
      }

      if (createResult != null && createResult.isFailure) {
        setModalState(() {
          isSubmitting = false;
          modalError =
              createResult!.error?.message ?? 'Failed to create course.';
        });
        return;
      }

      if (updateResult != null && updateResult.isFailure) {
        setModalState(() {
          isSubmitting = false;
          modalError =
              updateResult!.error?.message ?? 'Failed to update course.';
        });
        return;
      }

      setModalState(() {
        if (createResult != null) {
          courseId = createResult!.data;
        }
        isSubmitting = false;
        step = 2;
      });
    }

    Future<void> persistStepTwo(StateSetter setModalState) async {
      if (courseId == null) {
        setModalState(() => modalError = 'Create course details first.');
        return;
      }

      final maxCapacity = int.tryParse(maxCapacityController.text.trim()) ?? 0;
      if (maxCapacity <= 0) {
        setModalState(() => modalError = 'Capacity must be greater than zero.');
        return;
      }

      final sectionNumberText = sectionNumberController.text.trim();
      if (sectionNumberText.isEmpty) {
        setModalState(() => modalError = 'Section number is required.');
        return;
      }

      if (selectedSemesterId <= 0) {
        setModalState(() => modalError = 'Choose a valid semester.');
        return;
      }

      final start = _safeTime(startTimeController.text, fallback: '09:00');
      final end = _safeTime(endTimeController.text, fallback: '10:30');
      startTimeController.text = start;
      endTimeController.text = end;

      setModalState(() {
        isSubmitting = true;
        modalError = '';
      });

      final result = await _courseService.ensureSectionAndSchedule(
        courseId: courseId!,
        existingSectionId: sectionId,
        sectionNumber: sectionNumberText,
        maxCapacity: maxCapacity,
        location: locationController.text.trim(),
        semesterId: selectedSemesterId,
        scheduleDay: selectedDay,
        startTime: start,
        endTime: end,
      );

      if (!mounted) {
        return;
      }

      if (result.isFailure) {
        setModalState(() {
          isSubmitting = false;
          modalError =
              result.error?.message ?? 'Failed to save section schedule.';
        });
        return;
      }

      setModalState(() {
        sectionId = result.data;
        isSubmitting = false;
        step = 3;
      });
    }

    Future<void> finishFlow(StateSetter setModalState) async {
      if (courseId == null) {
        setModalState(() => modalError = 'Course setup is incomplete.');
        return;
      }

      setModalState(() {
        isSubmitting = true;
        modalError = '';
      });

      if (sectionId != null && sectionId! > 0) {
        final staffResult = await _courseService.syncStaffAssignments(
          sectionId: sectionId!,
          instructorId: selectedInstructorId,
          taIds: selectedTaIds,
        );

        if (!mounted) {
          return;
        }

        if (staffResult.isFailure) {
          setModalState(() {
            isSubmitting = false;
            modalError =
                staffResult.error?.message ??
                'Failed to save staff assignments.';
          });
          return;
        }
      }

      if (!mounted) {
        return;
      }

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await _loadBootstrap(silent: true);
      _showSnackBar(
        isEditing
            ? 'Course updated successfully.'
            : 'Course created successfully.',
      );
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final levelValue = _safeOption(
              selectedLevel,
              _levelOptions,
              fallback: 'FRESHMAN',
            );
            final statusValue = _safeOption(
              selectedStatus,
              _statusOptions,
              fallback: 'ACTIVE',
            );
            final dayValue = _safeOption(
              selectedDay,
              _weekdayOptions,
              fallback: 'Monday',
            );
            final semesterValue = _safeSemesterId(
              initialValue: selectedSemesterId,
              fallback: _semesters.isNotEmpty ? _semesters.first.id : 0,
            );
            final instructorValue = _safeStaffId(
              initialValue: selectedInstructorId,
              available: _instructors,
            );
            final departmentValue = _safeDepartmentId(
              initialValue: selectedDepartmentId,
              fallback: _departments.isNotEmpty ? _departments.first.id : 0,
            );

            selectedLevel = levelValue;
            selectedStatus = statusValue;
            selectedDay = dayValue;
            selectedSemesterId = semesterValue;
            selectedInstructorId = instructorValue;
            selectedDepartmentId = departmentValue;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 20,
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 780,
                  maxHeight: 720,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFF0EA5E9), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Edit Course Flow'
                                  : 'Add Course Flow',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (modalError.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AdminColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          modalError,
                          style: const TextStyle(
                            color: AdminColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Row(
                        children: [
                          _stepChip(step == 1, '1. Course'),
                          const SizedBox(width: 8),
                          _stepChip(step == 2, '2. Section'),
                          const SizedBox(width: 8),
                          _stepChip(step == 3, '3. Staff'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          children: [
                            if (step == 1) ...[
                              _modalTextField(
                                controller: codeController,
                                label: 'Course Code',
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: nameController,
                                label: 'Course Name',
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: creditsController,
                                label: 'Credits',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<int>(
                                initialValue: departmentValue > 0
                                    ? departmentValue
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Department',
                                  border: OutlineInputBorder(),
                                ),
                                items: _departments
                                    .map(
                                      (department) => DropdownMenuItem<int>(
                                        value: department.id,
                                        child: Text(department.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(
                                    () => selectedDepartmentId = value,
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: levelValue,
                                decoration: const InputDecoration(
                                  labelText: 'Course Level',
                                  border: OutlineInputBorder(),
                                ),
                                items: _levelOptions
                                    .map(
                                      (level) => DropdownMenuItem<String>(
                                        value: level,
                                        child: Text(level),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(() => selectedLevel = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: statusValue,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: _statusOptions
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(() => selectedStatus = value);
                                },
                              ),
                            ],
                            if (step == 2) ...[
                              _modalTextField(
                                controller: sectionNumberController,
                                label: 'Section Number',
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: maxCapacityController,
                                label: 'Max Capacity',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: locationController,
                                label: 'Location',
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<int>(
                                initialValue: semesterValue > 0
                                    ? semesterValue
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Semester',
                                  border: OutlineInputBorder(),
                                ),
                                items: _semesters
                                    .map(
                                      (semester) => DropdownMenuItem<int>(
                                        value: semester.id,
                                        child: Text(semester.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(
                                    () => selectedSemesterId = value,
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: dayValue,
                                decoration: const InputDecoration(
                                  labelText: 'Day',
                                  border: OutlineInputBorder(),
                                ),
                                items: _weekdayOptions
                                    .map(
                                      (day) => DropdownMenuItem<String>(
                                        value: day,
                                        child: Text(day),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(() => selectedDay = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: startTimeController,
                                label: 'Start Time (HH:mm)',
                                keyboardType: TextInputType.datetime,
                              ),
                              const SizedBox(height: 10),
                              _modalTextField(
                                controller: endTimeController,
                                label: 'End Time (HH:mm)',
                                keyboardType: TextInputType.datetime,
                              ),
                            ],
                            if (step == 3) ...[
                              if (sectionId == null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Section setup was skipped. Staff assignment requires a section.',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              DropdownButtonFormField<int>(
                                initialValue: instructorValue,
                                decoration: const InputDecoration(
                                  labelText: 'Instructor',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('Select Instructor'),
                                  ),
                                  ..._instructors.map(
                                    (staff) => DropdownMenuItem<int>(
                                      value: staff.id,
                                      child: Text(staff.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setModalState(
                                    () => selectedInstructorId = value,
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _tas.map((ta) {
                                    final selected = selectedTaIds.contains(
                                      ta.id,
                                    );
                                    return FilterChip(
                                      selected: selected,
                                      label: Text(ta.name),
                                      onSelected: (next) {
                                        setModalState(() {
                                          if (next) {
                                            selectedTaIds = <int>[
                                              ...selectedTaIds,
                                              ta.id,
                                            ];
                                          } else {
                                            selectedTaIds = selectedTaIds
                                                .where((id) => id != ta.id)
                                                .toList();
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (step > 1)
                            OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => setModalState(() => step -= 1),
                              child: const Text('Back'),
                            ),
                          if (step > 1) const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: Text(l10n.cancel),
                          ),
                          const Spacer(),
                          if (step == 1)
                            FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => persistStepOne(setModalState),
                              child: Text(isSubmitting ? 'Saving...' : 'Next'),
                            ),
                          if (step == 2)
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () {
                                          setModalState(() {
                                            step = 3;
                                          });
                                        },
                                  child: const Text('Skip'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => persistStepTwo(setModalState),
                                  child: Text(
                                    isSubmitting ? 'Saving...' : 'Next',
                                  ),
                                ),
                              ],
                            ),
                          if (step == 3)
                            FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => finishFlow(setModalState),
                              child: Text(
                                isSubmitting
                                    ? 'Saving...'
                                    : (isEditing ? l10n.save : 'Create Course'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    codeController.dispose();
    nameController.dispose();
    creditsController.dispose();
    sectionNumberController.dispose();
    maxCapacityController.dispose();
    locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
  }

  Future<void> _openDeleteCourseDialog(
    AppLocalizations l10n,
    AdminManagedCourse course,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text(
            'Delete ${course.code} - ${course.name}? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AdminColors.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final result = await _courseService.deleteCourse(course.id);
    if (!mounted) {
      return;
    }

    if (result.isFailure) {
      _showSnackBar(
        result.error?.message ?? 'Failed to delete the selected course.',
        isError: true,
      );
      return;
    }

    _showSnackBar('Course deleted successfully.');
    _loadCoursesOnly(silent: true);
  }

  Widget _modalTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _stepChip(bool active, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AdminColors.primary
              : AdminColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : AdminColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AdminColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialLoadingState(bool isDark) {
    return Container(
      height: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Loading course management workspace...'),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _iconActionButton({
    required bool isDark,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? AdminColors.getTextSecondaryColor(isDark);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
      ),
    );
  }

  Widget _miniStat(
    bool isDark, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AdminColors.getTextSecondaryColor(isDark)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AdminColors.getTextSecondaryColor(isDark)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _safeSemesterId({required int? initialValue, required int fallback}) {
    final availableIds = _semesters.map((item) => item.id).toSet();
    if (initialValue != null && availableIds.contains(initialValue)) {
      return initialValue;
    }
    if (availableIds.contains(fallback)) {
      return fallback;
    }
    if (_semesters.isNotEmpty) {
      return _semesters.first.id;
    }
    return 0;
  }

  int _safeDepartmentId({required int? initialValue, required int fallback}) {
    final availableIds = _departments.map((item) => item.id).toSet();
    if (initialValue != null && availableIds.contains(initialValue)) {
      return initialValue;
    }
    if (availableIds.contains(fallback)) {
      return fallback;
    }
    if (_departments.isNotEmpty) {
      return _departments.first.id;
    }
    return 0;
  }

  int _safeStaffId({
    required int? initialValue,
    required List<AdminStaffOption> available,
  }) {
    final ids = available.map((item) => item.id).toSet();
    if (initialValue != null && ids.contains(initialValue)) {
      return initialValue;
    }
    return 0;
  }

  String _safeOption(
    String? value,
    List<String> options, {
    required String fallback,
  }) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (options.contains(normalized)) {
      return normalized;
    }

    final raw = (value ?? '').trim();
    if (options.contains(raw)) {
      return raw;
    }

    return options.contains(fallback) ? fallback : options.first;
  }

  String _safeTime(String? value, {required String fallback}) {
    final text = (value ?? '').trim();
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(text);
    if (match != null) {
      return '${match.group(1)}:${match.group(2)}';
    }
    return fallback;
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AdminColors.error : AdminColors.success,
        ),
      );
  }
}

class _HeaderFlowChip extends StatelessWidget {
  final String step;
  final String label;

  const _HeaderFlowChip({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
