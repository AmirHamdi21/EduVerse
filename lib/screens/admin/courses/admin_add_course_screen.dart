import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/admin_course_management/course_list_bloc.dart';
import '../../../bloc/admin_course_management/course_wizard_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/courses/course_model.dart';
import '../../../models/courses/instructor_assignment_model.dart';
import '../../../models/courses/schedule_model.dart';
import '../../../models/courses/section_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/semester_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/core/semester_model.dart';
import '../../../widgets/admin/courses/add_course_bottom_bar.dart';
import '../../../widgets/admin/courses/add_course_header.dart';
import '../../../widgets/admin/courses/add_course_progress_indicator.dart';
import '../../../widgets/admin/courses/course_ai_preview.dart';
import '../../../widgets/admin/courses/course_details_form.dart';
import '../../../widgets/admin/courses/course_settings.dart';
import '../../../widgets/admin/courses/course_staff_assignment.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

/// Admin Add/Edit Course Screen
class AdminAddCourseScreen extends StatefulWidget {
  final CourseModel? initialCourse;

  const AdminAddCourseScreen({super.key, this.initialCourse});

  @override
  State<AdminAddCourseScreen> createState() => _AdminAddCourseScreenState();
}

class _AdminAddCourseScreenState extends State<AdminAddCourseScreen>
    with SingleTickerProviderStateMixin {
  final _detailsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedSemester;
  int _credits = 3;

  bool _hasLabs = false;
  int _labCount = 0;
  int _maxStudents = 30;
  bool _isActive = true;
  List<CourseScheduleDraft> _schedules = const <CourseScheduleDraft>[
    CourseScheduleDraft(),
  ];

  String? _syllabusFileName;
  bool _isAnalyzing = false;
  int? _lastPrefilledCourseId;
  int? _lastRequestedCourseDetailsId;
  int? _lastHydratedStaffCourseId;
  bool _hasManualAssignmentEdits = false;

  List<InstructorAssignmentDraft> _assignments =
      const <InstructorAssignmentDraft>[InstructorAssignmentDraft()];

  late final CoreApiClient _coreApiClient;
  late final SemesterService _semesterService;
  List<StaffMemberOption> _apiStaffOptions = const <StaffMemberOption>[];
  List<DepartmentInfo> _availableDepartments = const <DepartmentInfo>[];
  List<SemesterModel> _availableSemesters = const <SemesterModel>[];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _coreApiClient = CoreApiClient(storageService: StorageService());
    _semesterService = SemesterService(coreApiClient: _coreApiClient);
    _loadAssignableStaffOptions();
    _loadDepartments();
    _loadSemesters();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _nameController.addListener(_onFormChanged);
    _codeController.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.initialCourse != null) {
        _requestCourseDetails(widget.initialCourse!.id);
      }

      context.read<CourseWizardBloc>().add(
        InitializeWizard(course: widget.initialCourse),
      );

      if (widget.initialCourse != null) {
        _prefillFromCourse(widget.initialCourse!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    _coreApiClient.dio.close(force: true);
    super.dispose();
  }

  void _onFormChanged() {
    setState(() => _isAnalyzing = true);
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    });
  }

  Future<void> _loadAssignableStaffOptions() async {
    const roleFilters = <String>['instructor', 'teaching_assistant'];
    final byId = <int, StaffMemberOption>{};

    for (final role in roleFilters) {
      try {
        final response = await _coreApiClient.dio.get(
          '/admin/users',
          queryParameters: <String, dynamic>{
            'page': 1,
            'size': 100,
            'role': role,
            'status': 'active',
          },
        );

        final users = _extractAdminUsers(response.data);
        for (final user in users) {
          final option = _toStaffOption(user);
          if (option == null) {
            continue;
          }
          byId[option.userId] = option;
        }
      } catch (_) {
        // Keep UI functional with fallback options from course details.
      }
    }

    if (!mounted) {
      return;
    }

    final options = byId.values.toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    setState(() {
      _apiStaffOptions = options;
    });
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await _coreApiClient.dio.get('/departments');
      final rows = _extractListPayload(response.data);

      final byId = <int, DepartmentInfo>{};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final department = DepartmentInfo(
          id: _parseNullableInt(row['id'] ?? row['departmentId']) ?? 0,
          name: (row['name'] ?? row['departmentName'])?.toString().trim() ?? '',
          code: (row['code'] ?? row['departmentCode'])?.toString().trim() ?? '',
        );

        if (department.id <= 0 || department.name.isEmpty) {
          continue;
        }
        byId[department.id] = department;
      }

      if (!mounted || byId.isEmpty) {
        return;
      }

      final departments = byId.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _availableDepartments = departments;
      });
    } catch (_) {
      // Keep fallback department options if backend lookup fails.
    }
  }

  Future<void> _loadSemesters() async {
    final result = await _semesterService.getAll();
    if (result.isFailure || result.data == null || !mounted) {
      return;
    }

    final semesters =
        result.data!
            .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    if (semesters.isEmpty) {
      return;
    }

    setState(() {
      _availableSemesters = semesters;
    });
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is! Map<String, dynamic>) {
      return const <dynamic>[];
    }

    final data = payload['data'];
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested;
      }
    }

    for (final value in payload.values) {
      if (value is List) {
        return value;
      }
    }

    return const <dynamic>[];
  }

  List<Map<String, dynamic>> _extractAdminUsers(dynamic payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is! Map<String, dynamic>) {
      return const <Map<String, dynamic>>[];
    }

    final directData = payload['data'];
    if (directData is List) {
      return directData.whereType<Map<String, dynamic>>().toList();
    }

    if (directData is Map<String, dynamic>) {
      final nestedData = directData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  StaffMemberOption? _toStaffOption(Map<String, dynamic> raw) {
    final userId = _parseNullableInt(raw['userId'] ?? raw['id']);
    if (userId == null || userId <= 0) {
      return null;
    }

    final fullName = raw['fullName']?.toString().trim() ?? '';
    final firstName = raw['firstName']?.toString().trim() ?? '';
    final lastName = raw['lastName']?.toString().trim() ?? '';
    final email = raw['email']?.toString().trim() ?? '';

    final combinedName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : combinedName.isNotEmpty
        ? combinedName
        : (email.isNotEmpty ? email : 'User #$userId');

    return StaffMemberOption(userId: userId, fullName: displayName);
  }

  int? _parseNullableInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseListBloc, CourseListState>(
      listener: (context, listState) {
        _maybeHydrateAssignmentsFromCourseList(listState);
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;

          return BlocConsumer<CourseWizardBloc, CourseWizardState>(
            listener: (context, wizardState) {
              final l10n = AppLocalizations.of(context);
              _handleWizardState(wizardState, isDark, l10n);
            },
            builder: (context, wizardState) {
              final l10n = AppLocalizations.of(context);
              final staffOptions = _resolveStaffOptions(
                context.watch<CourseListBloc>().state,
              );

              return Scaffold(
                backgroundColor: AdminColors.getBackgroundColor(isDark),
                body: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: <Widget>[
                        AddCourseHeader(
                          isDark: isDark,
                          isEditing: wizardState.isEditMode,
                          onReset: _resetLocalForm,
                        ),
                        AddCourseProgressIndicator(
                          isDark: isDark,
                          currentStep: wizardState.currentStep,
                          allowDirectNavigation:
                              wizardState.allowDirectStepNavigation,
                          onStepTapped: (step) {
                            context.read<CourseWizardBloc>().add(
                              GoToWizardStep(step),
                            );
                          },
                        ),
                        Expanded(
                          child: _buildBody(
                            isDark,
                            l10n,
                            wizardState,
                            staffOptions,
                          ),
                        ),
                        AddCourseBottomBar(
                          isDark: isDark,
                          currentStep: wizardState.currentStep,
                          isSubmitting: wizardState.isSubmitting,
                          onPrevious: () {
                            context.read<CourseWizardBloc>().add(
                              const PreviousWizardStep(),
                            );
                          },
                          onNext: () => _handleNext(wizardState),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    AppLocalizations l10n,
    CourseWizardState wizardState,
    List<StaffMemberOption> staffOptions,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        if (isWideScreen) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _buildFormContent(
                  isDark,
                  l10n,
                  wizardState,
                  staffOptions,
                ),
              ),
              Expanded(flex: 2, child: _buildAiPreview(isDark)),
            ],
          );
        }

        return _buildFormContent(
          isDark,
          l10n,
          wizardState,
          staffOptions,
          showAiPreview: true,
        );
      },
    );
  }

  Widget _buildFormContent(
    bool isDark,
    AppLocalizations l10n,
    CourseWizardState wizardState,
    List<StaffMemberOption> staffOptions, {
    bool showAiPreview = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentStep(isDark, l10n, wizardState, staffOptions),
          ),
          if (showAiPreview) ...<Widget>[
            const SizedBox(height: 16),
            CourseAiPreview(
              isDark: isDark,
              courseName: _nameController.text,
              courseCode: _codeController.text,
              department: _selectedDepartment,
              level: _selectedLevel,
              semester: _selectedSemester,
              instructor: _resolvePrimaryInstructorName(staffOptions),
              tas: _resolveTAList(staffOptions),
              maxStudents: _maxStudents,
              hasLabs: _hasLabs,
              labCount: _labCount,
              isAnalyzing: _isAnalyzing,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(
    bool isDark,
    AppLocalizations l10n,
    CourseWizardState wizardState,
    List<StaffMemberOption> staffOptions,
  ) {
    switch (wizardState.currentStep) {
      case 0:
        return CourseDetailsForm(
          key: const ValueKey('details'),
          isDark: isDark,
          isEditing: wizardState.isEditMode,
          formKey: _detailsFormKey,
          nameController: _nameController,
          codeController: _codeController,
          descriptionController: _descriptionController,
          selectedDepartment: _selectedDepartment,
          selectedLevel: _selectedLevel,
          selectedSemester: _selectedSemester,
          selectedCredits: _credits,
          departmentOptions: _departmentOptions(),
          semesterOptions: _semesterOptions(l10n),
          onDepartmentChanged: (value) =>
              setState(() => _selectedDepartment = value),
          onLevelChanged: (value) => setState(() => _selectedLevel = value),
          onSemesterChanged: (value) =>
              setState(() => _selectedSemester = value),
          onCreditsChanged: (value) => setState(() => _credits = value),
          onUploadSyllabus: _uploadSyllabus,
          syllabusFileName: _syllabusFileName,
          backendErrors: wizardState.validationErrors,
        );
      case 1:
        return CourseSettings(
          key: const ValueKey('settings'),
          isDark: isDark,
          hasLabs: _hasLabs,
          labCount: _labCount,
          maxStudents: _maxStudents,
          isActive: _isActive,
          locationController: _locationController,
          schedules: _schedules,
          onHasLabsChanged: (value) {
            setState(() {
              _hasLabs = value;
              if (!value) {
                _schedules = _schedules
                    .where((item) => !_isLabScheduleDraft(item))
                    .toList();
                _labCount = 0;
              }
            });
          },
          onLabCountChanged: (value) => setState(() => _labCount = value),
          onMaxStudentsChanged: (value) => setState(() => _maxStudents = value),
          onIsActiveChanged: (value) => setState(() => _isActive = value),
          onSchedulesChanged: (value) {
            setState(() {
              _schedules = value;
              _labCount = value.where(_isLabScheduleDraft).length;
              _hasLabs = _labCount > 0;
            });
          },
          onDeleteCourse:
              wizardState.isEditMode && wizardState.draftCourseId != null
              ? () => _confirmDeleteFromWizard(
                  wizardState.draftCourseId!,
                  isDark,
                  l10n,
                )
              : null,
        );
      case 2:
      default:
        return CourseStaffAssignment(
          key: const ValueKey('staff'),
          isDark: isDark,
          assignments: _assignments,
          availableStaff: staffOptions,
          onAssignmentsChanged: (value) {
            setState(() {
              _assignments = value;
              _hasManualAssignmentEdits = true;
            });
          },
        );
    }
  }

  Widget _buildAiPreview(bool isDark) {
    final staffOptions = _resolveStaffOptions(
      context.read<CourseListBloc>().state,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: CourseAiPreview(
        isDark: isDark,
        courseName: _nameController.text,
        courseCode: _codeController.text,
        department: _selectedDepartment,
        level: _selectedLevel,
        semester: _selectedSemester,
        instructor: _resolvePrimaryInstructorName(staffOptions),
        tas: _resolveTAList(staffOptions),
        maxStudents: _maxStudents,
        hasLabs: _hasLabs,
        labCount: _labCount,
        isAnalyzing: _isAnalyzing,
      ),
    );
  }

  void _handleNext(CourseWizardState wizardState) {
    if (wizardState.currentStep == 0) {
      final valid = _detailsFormKey.currentState?.validate() ?? false;
      if (!valid) {
        _showValidationError();
        return;
      }

      context.read<CourseWizardBloc>().add(
        SubmitStep1(
          _buildStep1Payload(wizardState.isEditMode),
          desiredStatus: _isActive ? 'ACTIVE' : 'INACTIVE',
        ),
      );
      return;
    }

    if (wizardState.currentStep == 1) {
      if (_maxStudents <= 0 || (_hasLabs && _labCount < 0)) {
        _showValidationError();
        return;
      }

      final schedulesPayload = _buildSchedulesPayload();
      if (schedulesPayload.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Please add at least one valid schedule entry.'),
              backgroundColor: AdminColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }

      context.read<CourseWizardBloc>().add(
        SubmitStep2(
          sectionPayload: _buildStep2SectionPayload(wizardState.isEditMode),
          schedulesPayload: schedulesPayload,
          desiredStatus: _isActive ? 'OPEN' : 'CLOSED',
        ),
      );
      return;
    }

    final mappedAssignments = _assignments
        .where((item) => item.userId != null)
        .map((item) {
          final normalizedRole = item.role.trim().toLowerCase();
          return WizardInstructorAssignment(
            userId: item.userId!,
            role: item.role,
            responsibilities: normalizedRole == 'ta'
                ? item.responsibilities
                : null,
          );
        })
        .toList();

    context.read<CourseWizardBloc>().add(SubmitStep3(mappedAssignments));
  }

  Map<String, dynamic> _buildStep1Payload(bool isEditing) {
    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'credits': _credits,
      'level': _toApiLevel(_selectedLevel),
    };

    if (isEditing) {
      payload['status'] = _isActive ? 'ACTIVE' : 'INACTIVE';
    }

    if (!isEditing) {
      payload['code'] = _codeController.text.trim().toUpperCase();
      payload['departmentId'] = _resolveDepartmentId(_selectedDepartment);
    }

    if (_syllabusFileName != null) {
      payload['syllabusUrl'] = _syllabusFileName;
    }

    return payload;
  }

  Map<String, dynamic> _buildStep2SectionPayload(bool isEditing) {
    final payload = <String, dynamic>{
      'maxCapacity': _maxStudents,
      if (_locationController.text.trim().isNotEmpty)
        'location': _locationController.text.trim(),
    };

    if (isEditing) {
      payload['status'] = _isActive ? 'OPEN' : 'CLOSED';
    }

    if (!isEditing) {
      payload['semesterId'] = _resolveSemesterId(_selectedSemester);
    }

    return payload;
  }

  List<Map<String, dynamic>> _buildSchedulesPayload() {
    return _schedules
        .where(
          (item) =>
              item.dayOfWeek.trim().isNotEmpty &&
              item.startTime.trim().isNotEmpty &&
              item.endTime.trim().isNotEmpty &&
              item.scheduleType.trim().isNotEmpty,
        )
        .map(
          (item) => <String, dynamic>{
            if (item.id != null) 'id': item.id,
            'dayOfWeek': item.dayOfWeek,
            'startTime': item.startTime,
            'endTime': item.endTime,
            'scheduleType': item.scheduleType,
          },
        )
        .toList();
  }

  int _resolveDepartmentId(String? value) {
    if (_availableDepartments.isEmpty) {
      return 1;
    }

    if (value == null || value.trim().isEmpty) {
      return _availableDepartments.first.id;
    }

    for (final department in _availableDepartments) {
      if (department.name == value) {
        return department.id;
      }
    }

    return _availableDepartments.first.id;
  }

  int _resolveSemesterId(String? value) {
    if (_availableSemesters.isEmpty) {
      return 1;
    }

    if (value == null || value.trim().isEmpty) {
      return _availableSemesters.first.id;
    }

    for (final semester in _availableSemesters) {
      if (semester.name == value) {
        return semester.id;
      }
    }

    return _availableSemesters.first.id;
  }

  List<String> _departmentOptions() {
    if (_availableDepartments.isNotEmpty) {
      return _availableDepartments.map((item) => item.name).toList();
    }

    return const <String>[
      'Computer Science',
      'Mathematics',
      'Physics',
      'Engineering',
      'English',
      'Chemistry',
      'Biology',
    ];
  }

  List<String> _semesterOptions(AppLocalizations l10n) {
    if (_availableSemesters.isNotEmpty) {
      return _availableSemesters.map((item) => item.name).toList();
    }

    return <String>[
      l10n.fallSemester,
      l10n.springSemester,
      l10n.summerSemester,
    ];
  }

  bool _isLabScheduleModel(ScheduleModel schedule) {
    return schedule.scheduleType.toJson().toUpperCase() == 'LAB';
  }

  bool _isLabScheduleDraft(CourseScheduleDraft draft) {
    return draft.scheduleType.toUpperCase() == 'LAB';
  }

  String _toApiLevel(String? localizedValue) {
    if (localizedValue == null) {
      return 'FRESHMAN';
    }

    final l10n = AppLocalizations.of(context);
    if (localizedValue == l10n.sophomore) {
      return 'SOPHOMORE';
    }
    if (localizedValue == l10n.junior) {
      return 'JUNIOR';
    }
    if (localizedValue == l10n.senior) {
      return 'SENIOR';
    }
    if (localizedValue == l10n.graduate) {
      return 'GRADUATE';
    }
    return 'FRESHMAN';
  }

  void _uploadSyllabus() {
    setState(() => _syllabusFileName = 'syllabus.pdf');
  }

  void _showValidationError() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.fillRequiredFields)),
            ],
          ),
          backgroundColor: AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _handleWizardState(
    CourseWizardState wizardState,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (wizardState.editingCourse != null) {
      _requestCourseDetails(wizardState.editingCourse!.id);
    }

    if (wizardState.editingCourse != null &&
        wizardState.editingCourse!.id != _lastPrefilledCourseId) {
      _prefillFromCourse(wizardState.editingCourse!);
    }

    if (wizardState.status == CourseWizardStatus.failure ||
        wizardState.status == CourseWizardStatus.conflict ||
        wizardState.status == CourseWizardStatus.inactiveSaved) {
      if (wizardState.errorMessage != null &&
          wizardState.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(wizardState.errorMessage!),
              backgroundColor:
                  wizardState.status == CourseWizardStatus.inactiveSaved
                  ? AdminColors.warning
                  : AdminColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    if (wizardState.status == CourseWizardStatus.stepSaved) {
      return;
    }

    if (wizardState.status == CourseWizardStatus.completed) {
      context.read<CourseListBloc>().add(const LoadCourses(forceRefresh: true));
      _showSuccessDialog(isDark, l10n, wizardState.isEditMode);
      context.read<CourseWizardBloc>().add(const ClearWizardFeedback());
    }
  }

  void _prefillFromCourse(CourseModel course) {
    _lastPrefilledCourseId = course.id;

    final sections = course.sections ?? const <SectionModel>[];
    final primarySection = sections.isNotEmpty ? sections.first : null;
    final schedules = sections
        .expand((section) => section.schedules ?? const <ScheduleModel>[])
        .toList();
    final listState = context.read<CourseListBloc>().state;
    final hasLoadedStaff = listState.staffByCourse.containsKey(course.id);
    final staffFromState =
        listState.staffByCourse[course.id] ??
        const <InstructorAssignmentModel>[];

    final assignmentDrafts = hasLoadedStaff
        ? _draftAssignmentsFromStaff(staffFromState)
        : _fallbackAssignmentDrafts(course);

    _nameController.text = course.name;
    _codeController.text = course.code;
    _descriptionController.text = course.description ?? '';
    _locationController.text = primarySection?.location ?? '';

    setState(() {
      _selectedDepartment = course.departmentName;
      _selectedLevel = _fromApiLevel(course.level);
      _selectedSemester = primarySection?.semester?.name;
      _credits = course.credits;
      _isActive = course.status != 'INACTIVE';
      _maxStudents = sections.isNotEmpty ? sections.first.maxCapacity : 30;
      _hasLabs = schedules.any(_isLabScheduleModel);
      _labCount = schedules.where(_isLabScheduleModel).length;
      _schedules = schedules
          .map(
            (item) => CourseScheduleDraft(
              id: item.id,
              dayOfWeek: item.dayOfWeek.toJson(),
              startTime: item.startTime,
              endTime: item.endTime,
              scheduleType: item.scheduleType.toJson(),
            ),
          )
          .toList();
      if (_schedules.isEmpty) {
        _schedules = const <CourseScheduleDraft>[CourseScheduleDraft()];
      }

      _assignments = assignmentDrafts;
      if (_assignments.isEmpty) {
        _assignments = const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(),
        ];
      }

      _hasManualAssignmentEdits = false;
      _lastHydratedStaffCourseId = hasLoadedStaff ? course.id : null;
    });
  }

  void _requestCourseDetails(int courseId) {
    if (_lastRequestedCourseDetailsId == courseId) {
      return;
    }

    _lastRequestedCourseDetailsId = courseId;
    context.read<CourseListBloc>().add(LoadCourseDetails(courseId));
  }

  int? _resolveEditingCourseId() {
    final wizardCourseId = context
        .read<CourseWizardBloc>()
        .state
        .editingCourse
        ?.id;
    return wizardCourseId ?? widget.initialCourse?.id;
  }

  void _maybeHydrateAssignmentsFromCourseList(CourseListState listState) {
    if (_hasManualAssignmentEdits) {
      return;
    }

    final courseId = _resolveEditingCourseId();
    if (courseId == null) {
      return;
    }

    if (!listState.staffByCourse.containsKey(courseId)) {
      return;
    }

    if (_lastHydratedStaffCourseId == courseId) {
      return;
    }

    final staffAssignments =
        listState.staffByCourse[courseId] ??
        const <InstructorAssignmentModel>[];
    final mappedAssignments = _draftAssignmentsFromStaff(staffAssignments);

    setState(() {
      _assignments = mappedAssignments.isNotEmpty
          ? mappedAssignments
          : const <InstructorAssignmentDraft>[InstructorAssignmentDraft()];
      _lastHydratedStaffCourseId = courseId;
    });
  }

  List<InstructorAssignmentDraft> _draftAssignmentsFromStaff(
    List<InstructorAssignmentModel> assignments,
  ) {
    return assignments
        .map(
          (assignment) => InstructorAssignmentDraft(
            userId: assignment.userId,
            role: assignment.role,
            responsibilities: assignment.responsibilities,
          ),
        )
        .toList();
  }

  List<InstructorAssignmentDraft> _fallbackAssignmentDrafts(
    CourseModel course,
  ) {
    final fallback = <InstructorAssignmentDraft>[];

    if (course.instructorId != null) {
      fallback.add(
        InstructorAssignmentDraft(userId: course.instructorId, role: 'primary'),
      );
    }

    for (final taId in course.taIds ?? const <int>[]) {
      fallback.add(InstructorAssignmentDraft(userId: taId, role: 'ta'));
    }

    return fallback;
  }

  String? _fromApiLevel(String? apiLevel) {
    if (apiLevel == null) {
      return null;
    }

    final l10n = AppLocalizations.of(context);
    switch (apiLevel.toUpperCase()) {
      case 'FRESHMAN':
        return l10n.freshman;
      case 'SOPHOMORE':
        return l10n.sophomore;
      case 'JUNIOR':
        return l10n.junior;
      case 'SENIOR':
        return l10n.senior;
      case 'GRADUATE':
        return l10n.graduate;
      default:
        return null;
    }
  }

  void _resetLocalForm() {
    _detailsFormKey.currentState?.reset();

    setState(() {
      _nameController.clear();
      _codeController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _selectedDepartment = null;
      _selectedLevel = null;
      _selectedSemester = null;
      _credits = 3;
      _hasLabs = false;
      _labCount = 0;
      _maxStudents = 30;
      _isActive = true;
      _schedules = const <CourseScheduleDraft>[CourseScheduleDraft()];
      _syllabusFileName = null;
      _assignments = const <InstructorAssignmentDraft>[
        InstructorAssignmentDraft(),
      ];
      _lastPrefilledCourseId = null;
      _lastRequestedCourseDetailsId = null;
      _lastHydratedStaffCourseId = null;
      _hasManualAssignmentEdits = false;
    });

    context.read<CourseWizardBloc>().add(const ResetWizard());
  }

  Future<void> _confirmDeleteFromWizard(
    int courseId,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        title: Text(
          l10n.confirmDelete,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Text(
          l10n.courseInactive,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (approved == true && mounted) {
      context.read<CourseWizardBloc>().add(DeleteCourseFromWizard(courseId));
    }
  }

  void _showSuccessDialog(bool isDark, AppLocalizations l10n, bool isEditMode) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AdminColors.greenGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditMode ? l10n.courseUpdated : l10n.courseCreatedSuccess,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.courseCreatedMessage,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _resetLocalForm();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.primary,
                      side: BorderSide(color: AdminColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.createAnother),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go('/admin/courses');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.viewCourses),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<StaffMemberOption> _resolveStaffOptions(CourseListState listState) {
    final byId = <int, StaffMemberOption>{};

    for (final staffList in listState.staffByCourse.values) {
      for (final item in staffList) {
        if (item.userId <= 0) {
          continue;
        }

        byId[item.userId] = StaffMemberOption(
          userId: item.userId,
          fullName: item.fullName,
        );
      }
    }

    for (final option in _apiStaffOptions) {
      if (option.userId <= 0) {
        continue;
      }
      byId[option.userId] = option;
    }

    for (final assignment in _assignments) {
      final userId = assignment.userId;
      if (userId == null || userId <= 0 || byId.containsKey(userId)) {
        continue;
      }

      byId[userId] = StaffMemberOption(
        userId: userId,
        fullName: 'User #$userId',
      );
    }

    final options = byId.values.toList();
    options.sort((a, b) => a.fullName.compareTo(b.fullName));
    return options;
  }

  String? _resolvePrimaryInstructorName(List<StaffMemberOption> options) {
    for (final assignment in _assignments) {
      if (assignment.role.toLowerCase() == 'ta') {
        continue;
      }

      final userId = assignment.userId;
      if (userId == null) {
        continue;
      }

      for (final option in options) {
        if (option.userId == userId) {
          return option.fullName;
        }
      }
    }
    return null;
  }

  List<String> _resolveTAList(List<StaffMemberOption> options) {
    final output = <String>[];

    for (final assignment in _assignments) {
      if (assignment.role.toLowerCase() != 'ta') {
        continue;
      }

      final userId = assignment.userId;
      if (userId == null) {
        continue;
      }

      for (final option in options) {
        if (option.userId == userId) {
          output.add(option.fullName);
          break;
        }
      }
    }

    return output;
  }
}
