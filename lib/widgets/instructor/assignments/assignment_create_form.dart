import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/assignments/assignment_form_data.dart';
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/assignment_service.dart';
import 'instruction_file_uploader.dart';

class AssignmentCreateForm extends StatefulWidget {
  const AssignmentCreateForm({
    super.key,
    required this.courses,
    required this.assignmentService,
    required this.onSubmit,
    this.initialData,
    this.assignmentId,
    this.submitting = false,
  });

  final List<TeachingCourseModel> courses;
  final AssignmentService assignmentService;
  final ValueChanged<AssignmentFormData> onSubmit;
  final AssignmentFormData? initialData;
  final int? assignmentId;
  final bool submitting;

  @override
  State<AssignmentCreateForm> createState() => AssignmentCreateFormState();
}

class AssignmentCreateFormState extends State<AssignmentCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _uploaderKey = GlobalKey<InstructionFileUploaderState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _weightController;
  late final TextEditingController _maxFileSizeController;
  late final TextEditingController _allowedTypesController;
  late final TextEditingController _latePenaltyController;

  int? _courseId;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  api.SubmissionType _submissionType = api.SubmissionType.file;
  api.AssignmentStatus _status = api.AssignmentStatus.draft;
  List<DriveFileModel> _uploadedInstructionFiles = <DriveFileModel>[];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _instructionsController = TextEditingController(
      text: initial?.instructions ?? '',
    );
    _maxScoreController = TextEditingController(
      text: (initial?.maxScore ?? 100).toString(),
    );
    _weightController = TextEditingController(
      text: (initial?.weight ?? 10).toString(),
    );
    _maxFileSizeController = TextEditingController(
      text: (initial?.maxFileSizeMb ?? 10).toString(),
    );
    _allowedTypesController = TextEditingController(
      text: initial?.allowedFileTypes.join(', ') ?? '',
    );
    _latePenaltyController = TextEditingController(
      text: (initial?.latePenaltyPercent ?? 0).toString(),
    );
    _uploadedInstructionFiles = List<DriveFileModel>.from(
      initial?.instructionFiles ?? const <DriveFileModel>[],
    );

    _courseId =
        initial?.courseId ??
        (widget.courses.isNotEmpty ? widget.courses.first.courseId : null);
    _dueDate = initial?.dueDate;
    if (_dueDate != null) {
      _dueTime = TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute);
    }
    _submissionType = initial?.submissionType ?? api.SubmissionType.file;
    _status = initial?.status ?? api.AssignmentStatus.draft;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    _maxFileSizeController.dispose();
    _allowedTypesController.dispose();
    _latePenaltyController.dispose();
    super.dispose();
  }

  Future<PendingInstructionUploadResult> uploadPendingInstructionFiles(
    int assignmentId,
  ) async {
    final uploaderState = _uploaderKey.currentState;
    if (uploaderState == null) {
      return const PendingInstructionUploadResult();
    }
    return uploaderState.uploadPendingFiles(assignmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _instructionsController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Instructions (Markdown)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _courseDropdown(),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: _dateButton(context)),
              const SizedBox(width: 8),
              Expanded(child: _timeButton(context)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _maxScoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Max Score *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePositiveNumber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _maxFileSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max File Size (MB)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePositiveInt,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _latePenaltyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Late Penalty %',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return 'Enter valid value';
                    }
                    if (parsed < 0 || parsed > 100) {
                      return 'Must be 0-100';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _allowedTypesController,
            decoration: const InputDecoration(
              labelText: 'Allowed File Types (comma-separated)',
              hintText: 'pdf, docx, zip',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _submissionTypeSelector(),
          const SizedBox(height: 12),
          _statusSelector(),
          const SizedBox(height: 12),
          InstructionFileUploader(
            key: _uploaderKey,
            assignmentId: widget.assignmentId ?? 0,
            assignmentService: widget.assignmentService,
            initialFiles: _uploadedInstructionFiles,
            onFilesChanged: (files) => _uploadedInstructionFiles = files,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: widget.submitting ? null : _submit,
            icon: widget.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(widget.submitting ? 'Saving...' : 'Save Assignment'),
          ),
        ],
      ),
    );
  }

  Widget _courseDropdown() {
    return DropdownButtonFormField<int>(
      value: _courseId,
      decoration: const InputDecoration(
        labelText: 'Course *',
        border: OutlineInputBorder(),
      ),
      items: widget.courses
          .map(
            (course) => DropdownMenuItem<int>(
              value: course.courseId,
              child: Text('${course.course.code} - ${course.course.name}'),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _courseId = value),
      validator: (value) => value == null ? 'Course is required' : null,
    );
  }

  Widget _dateButton(BuildContext context) {
    final dateLabel = _dueDate == null
        ? 'Select Due Date'
        : DateFormat('yyyy-MM-dd').format(_dueDate!);

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      icon: const Icon(Icons.calendar_today_rounded),
      label: Text(dateLabel),
    );
  }

  Widget _timeButton(BuildContext context) {
    final timeLabel = _dueTime == null
        ? 'Select Due Time'
        : _dueTime!.format(context);

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
        );
        if (picked != null) {
          setState(() => _dueTime = picked);
        }
      },
      icon: const Icon(Icons.access_time_rounded),
      label: Text(timeLabel),
    );
  }

  Widget _submissionTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: api.SubmissionType.values
          .where((type) => type != api.SubmissionType.unknown)
          .map(
            (type) => ChoiceChip(
              label: Text(_submissionTypeLabel(type)),
              selected: _submissionType == type,
              onSelected: (_) => setState(() => _submissionType = type),
            ),
          )
          .toList(),
    );
  }

  Widget _statusSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          <api.AssignmentStatus>[
                api.AssignmentStatus.draft,
                api.AssignmentStatus.published,
              ]
              .map(
                (status) => ChoiceChip(
                  label: Text(_statusLabel(status)),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                ),
              )
              .toList(),
    );
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter number > 0';
    }
    return null;
  }

  String? _validatePositiveInt(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter integer > 0';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Due date is required')));
      return;
    }

    final dueTime = _dueTime ?? const TimeOfDay(hour: 23, minute: 59);
    final selectedDate = _dueDate!;
    late final DateTime dueDateTime;
    if (selectedDate.isUtc) {
      final localDate = selectedDate.toLocal();
      dueDateTime = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
        dueTime.hour,
        dueTime.minute,
      );
    } else {
      dueDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        dueTime.hour,
        dueTime.minute,
      );
    }

    final maxScore = double.parse(_maxScoreController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final maxFileSize = int.tryParse(_maxFileSizeController.text.trim());
    final latePenalty = double.tryParse(_latePenaltyController.text.trim());

    final allowed = _allowedTypesController.text
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    widget.onSubmit(
      AssignmentFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        dueDate: dueDateTime.toUtc(),
        maxScore: maxScore,
        weight: weight,
        submissionType: _submissionType,
        maxFileSizeMb: maxFileSize,
        allowedFileTypes: allowed,
        latePenaltyPercent: latePenalty,
        status: _status,
        courseId: _courseId!,
      ),
    );
  }

  static String _submissionTypeLabel(api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return 'File';
      case api.SubmissionType.text:
        return 'Text';
      case api.SubmissionType.link:
        return 'Link';
      case api.SubmissionType.multiple:
        return 'Multiple';
      case api.SubmissionType.unknown:
        return 'Unknown';
    }
  }

  static String _statusLabel(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return 'Draft';
      case api.AssignmentStatus.published:
        return 'Published';
      case api.AssignmentStatus.closed:
        return 'Closed';
      case api.AssignmentStatus.archived:
        return 'Archived';
      case api.AssignmentStatus.unknown:
        return 'Unknown';
    }
  }
}
