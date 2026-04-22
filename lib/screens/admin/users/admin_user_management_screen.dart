import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/service_error.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_student_management_models.dart';
import '../../../services/api/admin_student_management_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

/// Website-parity student management with live endpoint data.
class AdminUserManagementScreen extends StatefulWidget {
  final AdminStudentManagementService? studentService;
  final bool openCreateOnStart;
  final int? openEditStudentId;

  const AdminUserManagementScreen({
    super.key,
    this.studentService,
    this.openCreateOnStart = false,
    this.openEditStudentId,
  });

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  CoreApiClient? _coreApiClient;
  late final AdminStudentManagementService _studentService;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _page = 1;
  final int _size = 10;
  int _totalPages = 1;
  int _totalStudents = 0;

  String _statusFilter = 'all';
  String _yearFilter = 'all';

  Timer? _searchDebounce;

  List<AdminStudentModel> _students = const <AdminStudentModel>[];
  final Map<int, List<String>> _localEnrollments = <int, List<String>>{};
  bool _didRunInitialAction = false;

  static const List<String> _yearOptions = <String>[
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
  ];

  static const List<String> _editableStatusOptions = <String>[
    'active',
    'inactive',
    'suspended',
    'pending',
  ];

  static const List<String> _availableCourses = <String>[
    'CS101 - Introduction to Programming',
    'CS201 - Data Structures',
    'CS301 - Database Systems',
    'CS401 - AI Fundamentals',
    'MATH101 - Calculus I',
    'MATH205 - Discrete Mathematics',
    'PHY101 - Physics I',
    'ENG110 - Academic Writing',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.studentService != null) {
      _studentService = widget.studentService!;
    } else {
      _coreApiClient = CoreApiClient();
      _studentService = AdminStudentManagementService(
        coreApiClient: _coreApiClient!,
      );
    }

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadStudents();
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
      setState(() => _page = 1);
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _studentService.getStudents(
      page: _page,
      size: _size,
      search: _searchController.text,
      status: _statusFilter == 'all' ? null : _statusFilter,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure || result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.error?.message ??
            AppLocalizations.of(context).somethingWentWrong;
      });
      return;
    }

    final data = result.data!;
    final safeTotalPages = data.totalPages <= 0 ? 1 : data.totalPages;

    setState(() {
      _isLoading = false;
      _students = data.items;
      _totalPages = safeTotalPages;
      _totalStudents = data.total;
    });

    _maybeTriggerInitialAction();
  }

  void _maybeTriggerInitialAction() {
    if (_didRunInitialAction) {
      return;
    }

    if (!widget.openCreateOnStart && widget.openEditStudentId == null) {
      return;
    }

    _didRunInitialAction = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (widget.openEditStudentId != null) {
        final index = _students.indexWhere(
          (student) => student.id == widget.openEditStudentId,
        );
        if (index < 0) {
          _showSnackBar(
            'Student #${widget.openEditStudentId} was not found.',
            isError: true,
          );
          return;
        }

        await _openCreateOrEditStudentModal(
          student: _students[index],
          l10n: l10n,
        );
        return;
      }

      if (widget.openCreateOnStart) {
        await _openCreateOrEditStudentModal(l10n: l10n);
      }
    });
  }

  List<AdminStudentModel> get _displayedStudents {
    if (_yearFilter == 'all') {
      return _students;
    }

    return _students
        .where((student) => student.year.toLowerCase() == _yearFilter)
        .toList();
  }

  List<String> get _availableYearFilters {
    final years =
        _students
            .map((student) => student.year.trim())
            .where((year) => year.isNotEmpty && year.toLowerCase() != 'n/a')
            .toSet()
            .toList()
          ..sort();

    return <String>['all', ...years.map((year) => year.toLowerCase())];
  }

  List<String> _resolvedCourses(AdminStudentModel student) {
    final local = _localEnrollments[student.id];
    if (local != null) {
      return local;
    }
    return student.enrolledCourses;
  }

  Future<void> _openCreateOrEditStudentModal({
    AdminStudentModel? student,
    required AppLocalizations l10n,
  }) async {
    final isEditing = student != null;

    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: student?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: student?.lastName ?? '',
    );
    final emailController = TextEditingController(text: student?.email ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String selectedYear = _safeChoice(
      value: student?.year,
      allowedValues: _yearOptions,
      fallback: 'Freshman',
    );
    String selectedStatus = _safeChoice(
      value: student?.status,
      allowedValues: _editableStatusOptions,
      fallback: 'active',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? l10n.edit : l10n.addUser,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return l10n.required;
                            }
                            if (text.length < 2) {
                              return 'First name must be at least 2 characters';
                            }
                            if (text.length > 50) {
                              return 'First name cannot exceed 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: l10n.lastName,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return l10n.required;
                            }
                            if (text.length < 2) {
                              return 'Last name must be at least 2 characters';
                            }
                            if (text.length > 50) {
                              return 'Last name cannot exceed 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          readOnly: isEditing,
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty || !text.contains('@')) {
                              return l10n.invalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: l10n.phone,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return null;
                            }
                            if (!_isValidPhone(text)) {
                              return 'Phone must be in international format (e.g. +201234567890)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedYear,
                          decoration: InputDecoration(
                            labelText: l10n.academicYear,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Freshman',
                              child: Text(l10n.freshman),
                            ),
                            DropdownMenuItem(
                              value: 'Sophomore',
                              child: Text(l10n.sophomore),
                            ),
                            DropdownMenuItem(
                              value: 'Junior',
                              child: Text(l10n.junior),
                            ),
                            DropdownMenuItem(
                              value: 'Senior',
                              child: Text(l10n.senior),
                            ),
                            const DropdownMenuItem(
                              value: 'Graduate',
                              child: Text('Graduate'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() => selectedYear = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: InputDecoration(
                            labelText: l10n.status,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text(l10n.active),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text(l10n.inactive),
                            ),
                            const DropdownMenuItem(
                              value: 'suspended',
                              child: Text('Suspended'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text(l10n.pending),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() => selectedStatus = value);
                          },
                        ),
                        if (!isEditing) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final password = (value ?? '').trim();
                              if (!_isStrongPassword(password)) {
                                return 'Password must be at least 8 chars and include upper, lower, number, and special character';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: l10n.confirmPassword,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if ((value ?? '') != passwordController.text) {
                                return l10n.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }

                                        setState(() => _isSubmitting = true);

                                        late final ServiceResult<
                                          AdminStudentModel
                                        >
                                        response;

                                        if (isEditing) {
                                          final profileResult =
                                              await _studentService
                                                  .updateStudent(
                                                    id: student.id,
                                                    payload: <String, dynamic>{
                                                      'firstName':
                                                          firstNameController
                                                              .text
                                                              .trim(),
                                                      'lastName':
                                                          lastNameController
                                                              .text
                                                              .trim(),
                                                      'phone': phoneController
                                                          .text
                                                          .trim(),
                                                    },
                                                  );

                                          if (profileResult.isFailure) {
                                            response = profileResult;
                                          } else {
                                            final currentStatus = student.status
                                                .trim()
                                                .toLowerCase();

                                            if (selectedStatus !=
                                                currentStatus) {
                                              final statusResult =
                                                  await _studentService
                                                      .updateStudentStatus(
                                                        id: student.id,
                                                        status: selectedStatus,
                                                      );
                                              response = statusResult;
                                            } else {
                                              response = profileResult;
                                            }
                                          }
                                        } else {
                                          response = await _studentService
                                              .createStudent(
                                                firstName: firstNameController
                                                    .text
                                                    .trim(),
                                                lastName: lastNameController
                                                    .text
                                                    .trim(),
                                                email: emailController.text
                                                    .trim(),
                                                password:
                                                    passwordController.text,
                                                phone: phoneController.text
                                                    .trim(),
                                              );
                                        }

                                        if (!mounted) {
                                          return;
                                        }

                                        setState(() => _isSubmitting = false);

                                        if (response.isFailure) {
                                          _showSnackBar(
                                            response.error?.message ??
                                                l10n.somethingWentWrong,
                                            isError: true,
                                          );
                                          return;
                                        }

                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.pop(context);
                                        _showSnackBar(
                                          isEditing
                                              ? l10n.settingsSaved
                                              : l10n.userCreatedSuccessfully,
                                        );
                                        _page = 1;
                                        _loadStudents();
                                      },
                                child: Text(
                                  isEditing ? l10n.save : l10n.create,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _openAddCourseDialog(
    AdminStudentModel student,
    AppLocalizations l10n,
  ) async {
    final enrolled = _resolvedCourses(student);
    final notEnrolled = _availableCourses
        .where((course) => !enrolled.contains(course))
        .toList();

    if (notEnrolled.isEmpty) {
      _showSnackBar(l10n.noCoursesFound, isError: true);
      return;
    }

    String selectedCourse = notEnrolled.first;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(l10n.addCourse),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourse,
                    decoration: InputDecoration(
                      labelText: l10n.course,
                      border: const OutlineInputBorder(),
                    ),
                    items: notEnrolled
                        .map(
                          (course) => DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() => selectedCourse = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final next = <String>[...enrolled, selectedCourse];
                    setState(() {
                      _localEnrollments[student.id] = next;
                    });
                    Navigator.pop(context);
                    _showSnackBar(l10n.settingsSaved);
                  },
                  child: Text(l10n.addCourse),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openRemoveCourseDialog(
    AdminStudentModel student,
    AppLocalizations l10n,
  ) async {
    final enrolled = _resolvedCourses(student);
    if (enrolled.isEmpty) {
      _showSnackBar(l10n.noCoursesFound, isError: true);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.remove),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.fullName),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: enrolled
                    .map(
                      (course) => ActionChip(
                        label: Text(course),
                        avatar: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          final next = enrolled
                              .where((item) => item != course)
                              .toList();
                          setState(() {
                            _localEnrollments[student.id] = next;
                          });
                          Navigator.pop(context);
                          _showSnackBar(l10n.settingsSaved);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFixEnrollmentDialog(
    AdminStudentModel student,
    AppLocalizations l10n,
  ) async {
    final conflictList = <String>[
      'Schedule overlap detected in Monday 10:00-12:00',
      'Prerequisite mismatch for one selected course',
      'Capacity warning for one lab section',
    ];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fix Enrollment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.fullName),
              const SizedBox(height: 10),
              ...conflictList.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar(l10n.settingsSaved);
              },
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteStudent(
    AdminStudentModel student,
    AppLocalizations l10n,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.delete),
          content: Text('${l10n.deleteUserConfirmation} ${student.fullName}?'),
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

    setState(() => _isSubmitting = true);
    final result = await _studentService.deleteStudent(id: student.id);

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (result.isFailure) {
      _showSnackBar(
        result.error?.message ?? l10n.somethingWentWrong,
        isError: true,
      );
      return;
    }

    _showSnackBar(l10n.settingsSaved);
    _loadStudents();
  }

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

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AdminColors.success;
      case 'inactive':
        return AdminColors.warning;
      case 'suspended':
        return AdminColors.error;
      case 'pending':
        return AdminColors.accent;
      case 'on-hold':
        return const Color(0xFF9C27B0);
      case 'graduated':
        return AdminColors.secondary;
      default:
        return AdminColors.getTextSecondaryColor(false);
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.active;
      case 'inactive':
        return l10n.inactive;
      case 'suspended':
        return 'Suspended';
      case 'pending':
        return l10n.pending;
      case 'on-hold':
        return 'On Hold';
      case 'graduated':
        return 'Graduated';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSubmitting
                ? null
                : () => _openCreateOrEditStudentModal(l10n: l10n),
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(l10n.addUser),
          ),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: RefreshIndicator(
                onRefresh: _loadStudents,
                color: AdminColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    _buildTopBar(isDark, l10n),
                    const SizedBox(height: 14),
                    _buildHeroStats(l10n),
                    const SizedBox(height: 14),
                    _buildFilterCard(isDark, l10n),
                    const SizedBox(height: 14),
                    if (_isLoading) _buildLoadingState(isDark),
                    if (!_isLoading && _errorMessage != null)
                      _buildErrorState(isDark, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _displayedStudents.isEmpty)
                      _buildEmptyState(isDark, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _displayedStudents.isNotEmpty)
                      ..._displayedStudents.map(
                        (student) => _buildStudentCard(student, isDark, l10n),
                      ),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _displayedStudents.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildPaginationCard(isDark, l10n),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.manageStudents,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Website parity flow with live endpoints',
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : _loadStudents,
          icon: Icon(Icons.refresh_rounded, color: AdminColors.primary),
        ),
      ],
    );
  }

  Widget _buildHeroStats(AppLocalizations l10n) {
    final activeCount = _students
        .where((student) => student.status == 'active')
        .length;
    final pendingCount = _students
        .where((student) => student.status == 'pending')
        .length;
    final flaggedCount = _students
        .where(
          (student) =>
              student.status == 'inactive' || student.status == 'on-hold',
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0891B2), Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Operations Center',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Real API data plus parity actions from website flow',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroStatChip('Total', _totalStudents.toString()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStatChip(l10n.active, activeCount.toString()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStatChip(
                  l10n.pending,
                  pendingCount.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStatChip('Flagged', flaggedCount.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(bool isDark, AppLocalizations l10n) {
    final availableYearFilters = _availableYearFilters;
    final safeYearFilter = availableYearFilters.contains(_yearFilter)
        ? _yearFilter
        : 'all';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(color: AdminColors.getTextColor(isDark)),
            decoration: InputDecoration(
              hintText: l10n.searchStudents,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _page = 1;
                        _loadStudents();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('all', l10n.all, l10n),
              _buildStatusChip('active', l10n.active, l10n),
              _buildStatusChip('inactive', l10n.inactive, l10n),
              _buildStatusChip('pending', l10n.pending, l10n),
              _buildStatusChip('on-hold', 'On Hold', l10n),
              _buildStatusChip('graduated', 'Graduated', l10n),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'year-filter-$safeYearFilter-${availableYearFilters.length}',
            ),
            initialValue: safeYearFilter,
            decoration: InputDecoration(
              labelText: l10n.academicYear,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: availableYearFilters
                .map(
                  (year) => DropdownMenuItem<String>(
                    value: year,
                    child: Text(year == 'all' ? 'All Years' : year),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _yearFilter = value);
            },
          ),
        ],
      ),
    );
  }

  String _safeChoice({
    required String? value,
    required List<String> allowedValues,
    required String fallback,
  }) {
    final raw = (value ?? '').trim();
    if (allowedValues.contains(raw)) {
      return raw;
    }

    final lower = raw.toLowerCase();
    for (final option in allowedValues) {
      if (option.toLowerCase() == lower) {
        return option;
      }
    }

    return fallback;
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(password);

    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  Widget _buildStatusChip(String value, String label, AppLocalizations l10n) {
    final selected = _statusFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _statusFilter = value;
          _page = 1;
        });
        _loadStudents();
      },
      selectedColor: AdminColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminColors.primary,
      side: BorderSide(
        color: selected ? AdminColors.primary : const Color(0xFFCBD5E1),
      ),
      labelStyle: TextStyle(
        color: selected ? AdminColors.primary : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStudentCard(
    AdminStudentModel student,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final courses = _resolvedCourses(student);
    final statusColor = _statusColor(student.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF0891B2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    student.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.email,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(student.status, l10n),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetaChip(
                Icons.badge_outlined,
                l10n.studentId,
                student.studentId,
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                Icons.calendar_today_outlined,
                l10n.year,
                student.year,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${l10n.courses}:',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (courses.isEmpty)
            Text(
              l10n.noCoursesFound,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: courses
                  .map(
                    (course) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        course,
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: l10n.edit,
                onTap: _isSubmitting
                    ? null
                    : () => _openCreateOrEditStudentModal(
                        student: student,
                        l10n: l10n,
                      ),
              ),
              _buildActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: l10n.addCourse,
                onTap: () => _openAddCourseDialog(student, l10n),
              ),
              _buildActionButton(
                icon: Icons.remove_circle_outline_rounded,
                label: l10n.remove,
                onTap: () => _openRemoveCourseDialog(student, l10n),
              ),
              _buildActionButton(
                icon: Icons.build_circle_outlined,
                label: 'Fix Enrollment',
                onTap: () => _openFixEnrollmentDialog(student, l10n),
              ),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: l10n.delete,
                destructive: true,
                onTap: _isSubmitting
                    ? null
                    : () => _confirmDeleteStudent(student, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$label: $value',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool destructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: destructive ? AdminColors.error : AdminColors.primary,
        side: BorderSide(
          color: destructive
              ? AdminColors.error.withValues(alpha: 0.5)
              : AdminColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildPaginationCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l10n.page} $_page ${l10n.of_} $_totalPages',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: _page > 1
                ? () {
                    setState(() => _page--);
                    _loadStudents();
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: _page < _totalPages
                ? () {
                    setState(() => _page++);
                    _loadStudents();
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Loading students...',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AdminColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage ?? l10n.somethingWentWrong,
                  style: TextStyle(color: AdminColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 52, color: AdminColors.primary),
          const SizedBox(height: 10),
          Text(
            l10n.noStudentsFound,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noStudentsFoundSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }
}
