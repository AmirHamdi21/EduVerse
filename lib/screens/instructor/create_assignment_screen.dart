import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/instructor/instructor_assignments_cubit.dart';
import '../../bloc/instructor/instructor_assignments_state.dart';
import '../../models/assignments/assignment_form_data.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/core/drive_file_model.dart';
import '../../services/api/assignment_service.dart';
import '../../services/api/core_api_client.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/instructor/assignments/assignment_create_form.dart';

class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({
    super.key,
    this.assignment,
    this.assignmentId,
    this.assignmentService,
    this.enrollmentService,
  });

  final AssignmentModel? assignment;
  final int? assignmentId;
  final AssignmentService? assignmentService;
  final EnrollmentService? enrollmentService;

  @override
  Widget build(BuildContext context) {
    final coreApiClient = CoreApiClient(storageService: StorageService());
    final resolvedAssignmentService =
        assignmentService ?? AssignmentService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorAssignmentsCubit>(
      create: (_) => InstructorAssignmentsCubit(
        assignmentService: resolvedAssignmentService,
        enrollmentService: resolvedEnrollmentService,
      )..loadTeachingCourses(),
      child: _CreateAssignmentView(
        assignment: assignment,
        assignmentId: assignmentId,
        assignmentService: resolvedAssignmentService,
      ),
    );
  }
}

class _CreateAssignmentView extends StatefulWidget {
  const _CreateAssignmentView({
    this.assignment,
    this.assignmentId,
    required this.assignmentService,
  });

  final AssignmentModel? assignment;
  final int? assignmentId;
  final AssignmentService assignmentService;

  @override
  State<_CreateAssignmentView> createState() => _CreateAssignmentViewState();
}

class _CreateAssignmentViewState extends State<_CreateAssignmentView> {
  final _assignmentFormKey = GlobalKey<AssignmentCreateFormState>();

  bool _submitting = false;
  bool _fetchingAssignment = false;
  bool _warnOnMaxScoreChange = false;
  int? _activeAssignmentId;
  AssignmentModel? _fetchedAssignment;

  @override
  void initState() {
    super.initState();
    _activeAssignmentId =
        widget.assignmentId ?? widget.assignment?.assignmentId;

    if ((_activeAssignmentId ?? 0) > 0) {
      _fetchFreshAssignment();
    }
  }

  Future<void> _fetchFreshAssignment() async {
    if ((_activeAssignmentId ?? 0) <= 0) {
      return;
    }

    setState(() => _fetchingAssignment = true);

    final result = await widget.assignmentService.getById(_activeAssignmentId!);

    if (!mounted) {
      return;
    }

    if (result.isSuccess && result.data != null) {
      setState(() {
        _fetchedAssignment = result.data;
        _fetchingAssignment = false;
      });
      return;
    }

    setState(() => _fetchingAssignment = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = (_activeAssignmentId ?? 0) > 0;
    final effectiveAssignment = _fetchedAssignment ?? widget.assignment;
    final initialData = _toInitialData(effectiveAssignment);

    if (_fetchingAssignment) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocConsumer<InstructorAssignmentsCubit, InstructorAssignmentsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'Edit Assignment' : 'Create Assignment'),
            actions: <Widget>[
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
          body: state.isLoading && state.teachingCourses.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    if (_warnOnMaxScoreChange)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'Max score changed while editing. Review existing graded submissions for consistency.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    Expanded(
                      child: AssignmentCreateForm(
                        key: _assignmentFormKey,
                        courses: state.teachingCourses,
                        assignmentService: widget.assignmentService,
                        initialData: initialData,
                        assignmentId: _activeAssignmentId,
                        submitting: _submitting,
                        onSubmit: (data) => _submit(context, data, initialData),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context,
    AssignmentFormData data,
    AssignmentFormData? initialData,
  ) async {
    final cubit = context.read<InstructorAssignmentsCubit>();
    final editId = _activeAssignmentId ?? widget.assignment?.assignmentId ?? 0;
    final isEdit = editId > 0;

    if (initialData != null && initialData.maxScore != data.maxScore) {
      setState(() => _warnOnMaxScoreChange = true);
    }

    setState(() => _submitting = true);

    if (isEdit) {
      await cubit.updateAssignment(editId, data);
    } else {
      await cubit.createAssignment(data);
    }

    if (!mounted) {
      return;
    }

    if (cubit.state.errorMessage != null) {
      setState(() => _submitting = false);
      return;
    }

    final savedAssignmentId = isEdit
        ? editId
        : _resolveCreatedAssignmentId(cubit.state, data);

    if (savedAssignmentId > 0 && _activeAssignmentId != savedAssignmentId) {
      setState(() {
        _activeAssignmentId = savedAssignmentId;
      });
    }

    var uploadedCount = 0;
    var failedCount = 0;
    var failedFileNames = <String>[];
    final formState = _assignmentFormKey.currentState;
    if (formState != null) {
      final uploadResult = await formState.uploadPendingInstructionFiles(
        savedAssignmentId,
      );
      uploadedCount = uploadResult.successCount;
      failedCount = uploadResult.failureCount;
      failedFileNames = uploadResult.failedFileNames;
    }

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    if (isEdit && cubit.state.selectedCourseId != null) {
      await cubit.loadAssignments(page: 1, limit: 20, refresh: true);
      if (!mounted) {
        return;
      }
    }

    if (failedCount > 0) {
      final failedPreview = failedFileNames.take(2).join(', ');
      final suffix = failedPreview.isEmpty ? '' : ': $failedPreview';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assignment saved, but $failedCount instruction file(s) failed to upload$suffix. Use Retry in the file list.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final baseMessage = isEdit ? 'Assignment updated' : 'Assignment created';
    final successMessage = uploadedCount > 0
        ? '$baseMessage with $uploadedCount instruction file(s)'
        : baseMessage;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
    Navigator.of(context).pop(true);
  }

  int _resolveCreatedAssignmentId(
    InstructorAssignmentsState state,
    AssignmentFormData submittedData,
  ) {
    final assignments = state.assignments?.data;
    if (assignments == null || assignments.isEmpty) {
      return 0;
    }

    for (final assignment in assignments) {
      if (assignment.courseId == submittedData.courseId &&
          assignment.title.trim().toLowerCase() ==
              submittedData.title.trim().toLowerCase() &&
          assignment.assignmentId > 0) {
        return assignment.assignmentId;
      }
    }

    final first = assignments.first;
    if (first.assignmentId > 0) {
      return first.assignmentId;
    }
    return int.tryParse(first.id) ?? 0;
  }

  static AssignmentFormData? _toInitialData(AssignmentModel? assignment) {
    if (assignment == null) {
      return null;
    }

    DateTime? localDueDate;
    if (assignment.dueDate.isUtc) {
      localDueDate = assignment.dueDate.toLocal();
    } else {
      localDueDate = assignment.dueDate;
    }

    return AssignmentFormData(
      title: assignment.title,
      description: assignment.description,
      instructions: assignment.instructionsText,
      dueDate: localDueDate,
      maxScore: assignment.maxGrade,
      weight: assignment.weight,
      submissionType: assignment.submissionType,
      maxFileSizeMb: assignment.maxFileSizeMb,
      allowedFileTypes: assignment.allowedFileTypes ?? const <String>[],
      latePenaltyPercent: assignment.latePenaltyPercent,
      status: assignment.apiStatus,
      courseId: assignment.courseId,
      instructionFiles: assignment.instructionFiles ?? const <DriveFileModel>[],
    );
  }
}
