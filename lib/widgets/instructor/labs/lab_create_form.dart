import 'package:flutter/material.dart';

import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';

class LabCreateForm extends StatefulWidget {
  const LabCreateForm({
    super.key,
    required this.courses,
    required this.onSubmit,
    this.onCancel,
    this.existingLab,
    this.submitting = false,
  });

  final List<TeachingCourseModel> courses;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback? onCancel;
  final LabModel? existingLab;
  final bool submitting;

  @override
  State<LabCreateForm> createState() => _LabCreateFormState();
}

class _LabCreateFormState extends State<LabCreateForm> {
  static const Set<String> _supportedTypes = <String>{
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'txt',
    'md',
    'zip',
  };

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _weightController;
  late final TextEditingController _allowedFileTypesController;
  late final TextEditingController _maxFileSizeController;

  int? _courseId;
  DateTime? _availableFrom;
  DateTime? _dueDate;
  api.LabStatus _status = api.LabStatus.draft;

  @override
  void initState() {
    super.initState();
    final initial = widget.existingLab;

    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _maxScoreController = TextEditingController(
      text: (initial?.maxScore ?? 100).toString(),
    );
    _weightController = TextEditingController(
      text: (initial?.weight ?? 10).toString(),
    );
    _allowedFileTypesController = TextEditingController(
      text: initial?.allowedFileTypes ?? '',
    );
    _maxFileSizeController = TextEditingController(
      text: initial?.maxFileSizeMb?.toString() ?? '',
    );

    _courseId = initial?.courseId;
    if (_courseId == null && widget.courses.isNotEmpty) {
      _courseId = widget.courses.first.courseId;
    }

    _availableFrom = initial?.availableFrom ?? _buildDefaultAvailableFrom();
    _dueDate = initial?.dueDate ?? _buildDefaultDueDate();

    _status = initial?.status == api.LabStatus.published
        ? api.LabStatus.published
        : api.LabStatus.draft;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    _allowedFileTypesController.dispose();
    _maxFileSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingLab != null;
    final dueInPast = _dueDate != null && _dueDate!.isBefore(DateTime.now());
    final maxScoreLowered =
        isEdit &&
        widget.existingLab != null &&
        (double.tryParse(_maxScoreController.text.trim()) ??
                widget.existingLab!.maxScore) <
            widget.existingLab!.maxScore;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            isEdit ? 'Edit Lab' : 'Create New Lab',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildCourseDropdown(),
          const SizedBox(height: 12),
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
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildDateButton('Available From', _availableFrom, (
                  value,
                ) {
                  setState(() => _availableFrom = value);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateButton('Due Date', _dueDate, (value) {
                  setState(() => _dueDate = value);
                }),
              ),
            ],
          ),
          if (dueInPast)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _WarningBanner(
                message: "This lab's due date is in the past.",
              ),
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
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
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
          if (maxScoreLowered)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: _WarningBanner(
                message:
                    'Some submissions may have scores above the new maxScore. These scores are not adjusted automatically.',
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _allowedFileTypesController,
                  decoration: const InputDecoration(
                    labelText: 'Allowed File Types',
                    hintText: 'pdf, docx, zip',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateAllowedFileTypes,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _maxFileSizeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Max File Size (MB)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(value!.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusChips(),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.submitting ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.submitting ? null : _submit,
                  icon: widget.submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.submitting
                        ? 'Saving...'
                        : isEdit
                        ? 'Save Lab'
                        : 'Create Lab',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField<int>(
      key: ValueKey<int?>(_courseId),
      initialValue: _courseId,
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
          .toList(growable: false),
      onChanged: (value) => setState(() => _courseId = value),
      validator: (value) => value == null ? 'Course is required' : null,
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
  ) {
    final display = value == null
        ? label
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

    return OutlinedButton.icon(
      onPressed: () async {
        final now = DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: now.subtract(const Duration(days: 3650)),
          lastDate: now.add(const Duration(days: 3650)),
        );

        if (selectedDate == null || !mounted) {
          return;
        }

        final selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? now),
        );

        if (selectedTime == null) {
          return;
        }

        onChanged(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        );
      },
      icon: const Icon(Icons.event_rounded),
      label: Text(display),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: <api.LabStatus>[api.LabStatus.draft, api.LabStatus.published]
          .map(
            (status) => ChoiceChip(
              label: Text(
                status == api.LabStatus.draft ? 'Draft' : 'Published',
              ),
              selected: _status == status,
              onSelected: (_) => setState(() => _status = status),
            ),
          )
          .toList(growable: false),
    );
  }

  String? _validateAllowedFileTypes(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }

    final unknownTypes = raw
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty && !_supportedTypes.contains(item))
        .toList(growable: false);

    if (unknownTypes.isNotEmpty) {
      return 'Unsupported type(s): ${unknownTypes.join(', ')}';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_courseId == null || _dueDate == null || _availableFrom == null) {
      return;
    }

    final maxScore = double.tryParse(_maxScoreController.text.trim()) ?? 100;
    final weight = double.tryParse(_weightController.text.trim()) ?? 10;
    final maxFileSizeMb = _maxFileSizeController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxFileSizeController.text.trim());

    final allowed = _allowedFileTypesController.text
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    widget.onSubmit(<String, dynamic>{
      'courseId': _courseId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'availableFrom': _availableFrom!.toUtc().toIso8601String(),
      'dueDate': _dueDate!.toUtc().toIso8601String(),
      'maxScore': maxScore,
      'weight': weight,
      'status': _status.toJson(),
      'allowedFileTypes': allowed.isEmpty ? null : allowed.join(','),
      'maxFileSizeMb': maxFileSizeMb,
    });
  }

  DateTime _buildDefaultAvailableFrom() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 0, 0);
  }

  DateTime _buildDefaultDueDate() {
    final now = DateTime.now().add(const Duration(days: 7));
    return DateTime(now.year, now.month, now.day, 23, 59);
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
