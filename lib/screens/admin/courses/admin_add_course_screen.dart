import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/admin_course_management/course_list_bloc.dart';
import '../../../bloc/admin_course_management/course_wizard_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/courses/course_model.dart';
import '../../../models/courses/schedule_model.dart';
import '../../../models/courses/section_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
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

  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedSemester;

  bool _hasLabs = false;
  int _labCount = 0;
  int _maxStudents = 30;
  bool _isActive = true;

  String? _syllabusFileName;
  bool _isAnalyzing = false;
  int? _lastPrefilledCourseId;

  List<InstructorAssignmentDraft> _assignments =
      const <InstructorAssignmentDraft>[InstructorAssignmentDraft()];

  late final CoreApiClient _coreApiClient;
  List<StaffMemberOption> _apiStaffOptions = const <StaffMemberOption>[];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _coreApiClient = CoreApiClient(storageService: StorageService());
    _loadAssignableStaffOptions();

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
    return BlocBuilder<ThemeBloc, ThemeState>(
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
          onDepartmentChanged: (value) =>
              setState(() => _selectedDepartment = value),
          onLevelChanged: (value) => setState(() => _selectedLevel = value),
          onSemesterChanged: (value) =>
              setState(() => _selectedSemester = value),
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
          onHasLabsChanged: (value) => setState(() => _hasLabs = value),
          onLabCountChanged: (value) => setState(() => _labCount = value),
          onMaxStudentsChanged: (value) => setState(() => _maxStudents = value),
          onIsActiveChanged: (value) => setState(() => _isActive = value),
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
            setState(() => _assignments = value);
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
        SubmitStep1(_buildStep1Payload(wizardState.isEditMode)),
      );
      return;
    }

    if (wizardState.currentStep == 1) {
      if (_maxStudents <= 0 || (_hasLabs && _labCount < 0)) {
        _showValidationError();
        return;
      }

      context.read<CourseWizardBloc>().add(
        SubmitStep2(
          sectionPayload: _buildStep2SectionPayload(wizardState.isEditMode),
          schedulesPayload: const <Map<String, dynamic>>[],
        ),
      );
      return;
    }

    final mappedAssignments = _assignments
        .where((item) => item.userId != null)
        .map(
          (item) => WizardInstructorAssignment(
            userId: item.userId!,
            role: item.role,
            responsibilities: item.responsibilities,
          ),
        )
        .toList();

    context.read<CourseWizardBloc>().add(SubmitStep3(mappedAssignments));
  }

  Map<String, dynamic> _buildStep1Payload(bool isEditing) {
    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'credits': 3,
      'level': _toApiLevel(_selectedLevel),
      'status': _isActive ? 'ACTIVE' : 'INACTIVE',
    };

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
      'location': null,
      'status': _isActive ? 'OPEN' : 'CLOSED',
    };

    if (!isEditing) {
      payload['semesterId'] = _resolveSemesterId(_selectedSemester);
      payload['sectionNumber'] = 1;
    }

    return payload;
  }

  int _resolveDepartmentId(String? value) {
    final map = <String, int>{
      'Computer Science': 1,
      'Mathematics': 2,
      'Physics': 3,
      'Engineering': 4,
      'English': 5,
      'Chemistry': 6,
      'Biology': 7,
    };

    if (value == null) {
      return 1;
    }

    return map[value] ?? 1;
  }

  int _resolveSemesterId(String? value) {
    if (value == null) {
      return 1;
    }

    final l10n = AppLocalizations.of(context);
    if (value == l10n.springSemester) {
      return 2;
    }
    if (value == l10n.summerSemester) {
      return 3;
    }
    return 1;
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
      if (wizardState.currentStep == 1) {
        context.read<CourseWizardBloc>().add(const GoToWizardStep(1));
      } else if (wizardState.currentStep == 2) {
        context.read<CourseWizardBloc>().add(const GoToWizardStep(2));
      }
      return;
    }

    if (wizardState.status == CourseWizardStatus.completed) {
      _showSuccessDialog(isDark, l10n, wizardState.isEditMode);
      context.read<CourseWizardBloc>().add(const ClearWizardFeedback());
    }
  }

  void _prefillFromCourse(CourseModel course) {
    _lastPrefilledCourseId = course.id;

    final sections = course.sections ?? const <SectionModel>[];
    final schedules = sections
        .expand((section) => section.schedules ?? const <ScheduleModel>[])
        .toList();

    _nameController.text = course.name;
    _codeController.text = course.code;
    _descriptionController.text = course.description ?? '';

    setState(() {
      _selectedDepartment = course.departmentName;
      _selectedLevel = _fromApiLevel(course.level);
      _selectedSemester = null;
      _isActive = course.status != 'INACTIVE';
      _maxStudents = sections.isNotEmpty ? sections.first.maxCapacity : 30;
      _hasLabs = schedules.any(
        (schedule) => schedule.scheduleType.name.toLowerCase() == 'lab',
      );
      _labCount = schedules
          .where(
            (schedule) => schedule.scheduleType.name.toLowerCase() == 'lab',
          )
          .length;

      _assignments = <InstructorAssignmentDraft>[];
      if (course.instructorId != null) {
        _assignments.add(
          InstructorAssignmentDraft(
            userId: course.instructorId,
            role: 'primary',
          ),
        );
      }

      for (final taId in course.taIds ?? const <int>[]) {
        _assignments.add(InstructorAssignmentDraft(userId: taId, role: 'ta'));
      }

      if (_assignments.isEmpty) {
        _assignments = const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(),
        ];
      }
    });
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
      _selectedDepartment = null;
      _selectedLevel = null;
      _selectedSemester = null;
      _hasLabs = false;
      _labCount = 0;
      _maxStudents = 30;
      _isActive = true;
      _syllabusFileName = null;
      _assignments = const <InstructorAssignmentDraft>[
        InstructorAssignmentDraft(),
      ];
      _lastPrefilledCourseId = null;
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
