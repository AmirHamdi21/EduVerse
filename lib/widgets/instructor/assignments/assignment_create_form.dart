import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/assignments/assignment_form_data.dart';
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../ta/shared/ta_colors.dart';
import '../create_assignment/collapsible_section.dart';
import '../create_assignment/create_assignment_colors.dart';
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
    this.useTAColors = false,
  });

  final List<TeachingCourseModel> courses;
  final AssignmentService assignmentService;
  final ValueChanged<AssignmentFormData> onSubmit;
  final AssignmentFormData? initialData;
  final int? assignmentId;
  final bool submitting;
  final bool useTAColors;

  @override
  State<AssignmentCreateForm> createState() => AssignmentCreateFormState();
}

class AssignmentCreateFormState extends State<AssignmentCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _uploaderKey = GlobalKey<InstructionFileUploaderState>();
  static const List<String> _suggestedTypes = <String>[
    'pdf',
    'docx',
    'pptx',
    'zip',
    'png',
    'jpg',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _weightController;
  late final TextEditingController _maxFileSizeController;
  late final TextEditingController _allowedTypesController;
  late final TextEditingController _latePenaltyController;

  int? _courseId;
  DateTime? _availableFromDate;
  TimeOfDay? _availableFromTime;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  api.SubmissionType _submissionType = api.SubmissionType.file;
  api.AssignmentStatus _status = api.AssignmentStatus.draft;
  List<DriveFileModel> _uploadedInstructionFiles = <DriveFileModel>[];

  Color get _primaryColor =>
      widget.useTAColors ? TAColors.primary : CreateAssignmentColors.primary;
  Color get _assignmentColor =>
      widget.useTAColors ? TAColors.primary : CreateAssignmentColors.assignment;
  Color get _tealColor =>
      widget.useTAColors ? TAColors.teal : CreateAssignmentColors.teal;
  Color get _accentColor =>
      widget.useTAColors ? TAColors.accent : CreateAssignmentColors.accent;
  Color get _warningColor =>
      widget.useTAColors ? TAColors.warning : CreateAssignmentColors.warning;
  Color get _warningLightColor => widget.useTAColors
      ? TAColors.warningLight
      : CreateAssignmentColors.warningLight;
  LinearGradient get _heroGradient => widget.useTAColors
      ? TAColors.headerGradient
      : CreateAssignmentColors.assignmentGradient;

  Color _textPrimaryColor(bool isDark) => widget.useTAColors
      ? TAColors.textPrimaryColor(isDark)
      : CreateAssignmentColors.textPrimaryColor(isDark);
  Color _textSecondaryColor(bool isDark) => widget.useTAColors
      ? TAColors.textSecondaryColor(isDark)
      : CreateAssignmentColors.textSecondaryColor(isDark);
  Color _textTertiaryColor(bool isDark) => widget.useTAColors
      ? TAColors.textTertiaryColor(isDark)
      : CreateAssignmentColors.textTertiaryColor(isDark);
  Color _borderColor(bool isDark) => widget.useTAColors
      ? TAColors.borderColor(isDark)
      : CreateAssignmentColors.borderColor(isDark);
  Color _darkSurfaceColor() => widget.useTAColors
      ? TAColors.darkSurface
      : CreateAssignmentColors.darkSurface;
  Color _darkCardColor() =>
      widget.useTAColors ? TAColors.darkCard : CreateAssignmentColors.darkCard;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _titleController = TextEditingController(text: initial?.title ?? '')
      ..addListener(_refreshView);
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    )..addListener(_refreshView);
    _instructionsController = TextEditingController(
      text: initial?.instructions ?? '',
    )..addListener(_refreshView);
    _maxScoreController = TextEditingController(
      text: (initial?.maxScore ?? 100).toString(),
    )..addListener(_refreshView);
    _weightController = TextEditingController(
      text: (initial?.weight ?? 10).toString(),
    )..addListener(_refreshView);
    _maxFileSizeController = TextEditingController(
      text: (initial?.maxFileSizeMb ?? 10).toString(),
    )..addListener(_refreshView);
    _allowedTypesController = TextEditingController(
      text: initial?.allowedFileTypes.join(', ') ?? '',
    )..addListener(_refreshView);
    _latePenaltyController = TextEditingController(
      text: (initial?.latePenaltyPercent ?? 0).toString(),
    )..addListener(_refreshView);
    _uploadedInstructionFiles = List<DriveFileModel>.from(
      initial?.instructionFiles ?? const <DriveFileModel>[],
    );

    _courseId =
        initial?.courseId ??
        (widget.courses.isNotEmpty ? widget.courses.first.courseId : null);
    _availableFromDate =
        initial?.availableFrom ?? DateTime.now().add(const Duration(hours: 1));
    if (_availableFromDate != null) {
      _availableFromTime = TimeOfDay(
        hour: _availableFromDate!.hour,
        minute: _availableFromDate!.minute,
      );
    }
    _dueDate = initial?.dueDate;
    if (_dueDate != null) {
      _dueTime = TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute);
    }
    _submissionType = initial?.submissionType ?? api.SubmissionType.file;
    _status = initial?.status ?? api.AssignmentStatus.draft;
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_refreshView)
      ..dispose();
    _descriptionController
      ..removeListener(_refreshView)
      ..dispose();
    _instructionsController
      ..removeListener(_refreshView)
      ..dispose();
    _maxScoreController
      ..removeListener(_refreshView)
      ..dispose();
    _weightController
      ..removeListener(_refreshView)
      ..dispose();
    _maxFileSizeController
      ..removeListener(_refreshView)
      ..dispose();
    _allowedTypesController
      ..removeListener(_refreshView)
      ..dispose();
    _latePenaltyController
      ..removeListener(_refreshView)
      ..dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final responsive = ResponsiveUtil(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          _buildHeroCard(context, l10n, isDark),
          const SizedBox(height: 18),
          CollapsibleSection(
            title: l10n.instructorAssignmentOverviewSection,
            subtitle: l10n.instructorAssignmentOverviewSectionSubtitle,
            icon: Icons.auto_awesome_mosaic_rounded,
            isDark: isDark,
            accentColor: _assignmentColor,
            child: Column(
              children: <Widget>[
                _buildModernTextField(
                  context,
                  controller: _titleController,
                  label: l10n.title,
                  hint: l10n.instructorAssignmentTitleHint,
                  icon: Icons.title_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.instructorAssignmentValidationTitleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _courseDropdown(context, isDark, l10n, responsive),
                const SizedBox(height: 12),
                _buildModernTextField(
                  context,
                  controller: _descriptionController,
                  label: l10n.description,
                  hint: l10n.instructorAssignmentDescriptionHint,
                  icon: Icons.notes_rounded,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          CollapsibleSection(
            title: l10n.instructorAssignmentScheduleSection,
            subtitle: l10n.instructorAssignmentScheduleSectionSubtitle,
            icon: Icons.event_available_rounded,
            isDark: isDark,
            accentColor: _tealColor,
            child: Column(
              children: <Widget>[
                _buildScheduleCard(
                  context,
                  isDark: isDark,
                  title: l10n.availableFrom,
                  subtitle: l10n.instructorAssignmentAvailableHelper,
                  dateValue: _availableFromDate,
                  timeValue: _availableFromTime,
                  defaultDate: DateTime.now().add(const Duration(hours: 1)),
                  onDateChanged: (value) =>
                      setState(() => _availableFromDate = value),
                  onTimeChanged: (value) =>
                      setState(() => _availableFromTime = value),
                  accentColor: _primaryColor,
                ),
                const SizedBox(height: 12),
                _buildScheduleCard(
                  context,
                  isDark: isDark,
                  title: l10n.dueDate,
                  subtitle: l10n.instructorAssignmentDueHelper,
                  dateValue: _dueDate,
                  timeValue: _dueTime,
                  defaultDate: DateTime.now().add(const Duration(days: 7)),
                  onDateChanged: (value) => setState(() => _dueDate = value),
                  onTimeChanged: (value) => setState(() => _dueTime = value),
                  accentColor: _warningColor,
                ),
              ],
            ),
          ),
          CollapsibleSection(
            title: l10n.instructorAssignmentSettingsSection,
            subtitle: l10n.instructorAssignmentSettingsSectionSubtitle,
            icon: Icons.tune_rounded,
            isDark: isDark,
            accentColor: _accentColor,
            child: Column(
              children: <Widget>[
                _buildResponsiveFields(<Widget>[
                  _buildModernTextField(
                    context,
                    controller: _maxScoreController,
                    label: l10n.instructorAssignmentMaxScore,
                    hint: '100',
                    icon: Icons.star_border_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validatePositiveNumber,
                  ),
                  _buildModernTextField(
                    context,
                    controller: _weightController,
                    label: l10n.instructorAssignmentWeight,
                    hint: '10',
                    icon: Icons.pie_chart_outline_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  _buildModernTextField(
                    context,
                    controller: _maxFileSizeController,
                    label: l10n.assignmentMaxFileSize,
                    hint: '10 MB',
                    icon: Icons.sd_storage_rounded,
                    keyboardType: TextInputType.number,
                    validator: _validatePositiveInt,
                  ),
                  _buildModernTextField(
                    context,
                    controller: _latePenaltyController,
                    label: l10n.assignmentLatePenalty,
                    hint: '0 - 100%',
                    icon: Icons.timelapse_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').trim());
                      if (parsed == null) {
                        return l10n.instructorAssignmentValidationValidValue;
                      }
                      if (parsed < 0 || parsed > 100) {
                        return l10n.instructorAssignmentValidationZeroToHundred;
                      }
                      return null;
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                _buildResponsiveFields(<Widget>[
                  _selectionDropdown<api.SubmissionType>(
                    context,
                    isDark: isDark,
                    label: l10n.assignmentSubmissionType,
                    icon: Icons.upload_file_rounded,
                    value: _submissionType,
                    items: api.SubmissionType.values
                        .where((type) => type != api.SubmissionType.unknown)
                        .map(
                          (type) => DropdownMenuItem<api.SubmissionType>(
                            value: type,
                            child: Text(_submissionTypeLabel(l10n, type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _submissionType = value);
                      }
                    },
                  ),
                  _selectionDropdown<api.AssignmentStatus>(
                    context,
                    isDark: isDark,
                    label: l10n.instructorAssignmentVisibility,
                    icon: Icons.visibility_outlined,
                    value: _status,
                    items:
                        <api.AssignmentStatus>[
                              api.AssignmentStatus.draft,
                              api.AssignmentStatus.published,
                              api.AssignmentStatus.closed,
                              api.AssignmentStatus.archived,
                            ]
                            .map(
                              (status) =>
                                  DropdownMenuItem<api.AssignmentStatus>(
                                    value: status,
                                    child: Text(_statusLabel(l10n, status)),
                                  ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                _buildModernTextField(
                  context,
                  controller: _allowedTypesController,
                  label: l10n.assignmentAllowedFileTypes,
                  hint: l10n.instructorAssignmentAllowedTypesHint,
                  icon: Icons.attach_file_rounded,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _buildSuggestedTypes(context, isDark, l10n),
                if (_parsedAllowedTypes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _parsedAllowedTypes
                          .map(
                            (type) => _buildTypeChip(
                              context,
                              isDark: isDark,
                              value: type,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          CollapsibleSection(
            title: l10n.instructorAssignmentResourcesSection,
            subtitle: l10n.instructorAssignmentResourcesSectionSubtitle,
            icon: Icons.library_books_outlined,
            isDark: isDark,
            accentColor: _warningColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildModernTextField(
                  context,
                  controller: _instructionsController,
                  label: l10n.instructions,
                  hint: l10n.instructorAssignmentInstructionsHint,
                  icon: Icons.edit_note_rounded,
                  maxLines: 8,
                ),
                const SizedBox(height: 12),
                _buildInstructionTemplates(context, isDark, l10n),
                const SizedBox(height: 16),
                _buildUploaderContainer(context, isDark, l10n),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSaveButton(context, isDark, l10n),
        ],
      ),
    );
  }

  List<String> get _parsedAllowedTypes => _allowedTypesController.text
      .split(',')
      .map((item) => item.trim().toLowerCase())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);

  TeachingCourseModel? get _selectedCourse {
    for (final course in widget.courses) {
      if (course.courseId == _courseId) {
        return course;
      }
    }
    return null;
  }

  void _refreshView() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildHeroCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final selectedCourse = _selectedCourse;
    final title = _titleController.text.trim().isEmpty
        ? l10n.instructorAssignmentComposerTitle
        : _titleController.text.trim();
    final dueLabel = _dueDate == null
        ? l10n.assignmentNoDueDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_jm().format(
            _combineDateAndTime(
              _dueDate!,
              _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        gradient: _heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _assignmentColor.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -32,
            right: -18,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -42,
            left: -12,
            child: Container(
              width: 154,
              height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            l10n.instructorAssignmentComposerSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.95,
                  children: <Widget>[
                    _buildHeroMetric(
                      context,
                      icon: Icons.school_outlined,
                      label: l10n.course,
                      value: selectedCourse == null
                          ? l10n.noCoursesAvailable
                          : selectedCourse.course.code,
                    ),
                    _buildHeroMetric(
                      context,
                      icon: Icons.visibility_outlined,
                      label: l10n.instructorAssignmentVisibility,
                      value: _statusLabel(l10n, _status),
                    ),
                    _buildHeroMetric(
                      context,
                      icon: Icons.upload_file_outlined,
                      label: l10n.assignmentSubmissionType,
                      value: _submissionTypeLabel(l10n, _submissionType),
                    ),
                    _buildHeroMetric(
                      context,
                      icon: Icons.event_available_rounded,
                      label: l10n.dueDate,
                      value: dueLabel,
                    ),
                  ],
                ),
                if (selectedCourse != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.auto_stories_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${selectedCourse.course.code} • ${selectedCourse.course.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required DateTime? dateValue,
    required TimeOfDay? timeValue,
    required DateTime defaultDate,
    required ValueChanged<DateTime> onDateChanged,
    required ValueChanged<TimeOfDay> onTimeChanged,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? _darkSurfaceColor().withValues(alpha: 0.55)
            : accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: _textPrimaryColor(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _textSecondaryColor(isDark),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _buildResponsiveFields(<Widget>[
            _dateButton(
              context,
              isDark: isDark,
              dateValue: dateValue,
              defaultDate: defaultDate,
              onChanged: onDateChanged,
              accentColor: accentColor,
            ),
            _timeButton(
              context,
              isDark: isDark,
              timeValue: timeValue,
              onChanged: onTimeChanged,
              accentColor: accentColor,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildResponsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isTwoColumn = constraints.maxWidth >= 640;
        if (!isTwoColumn) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        final rows = <Widget>[];
        for (var index = 0; index < children.length; index += 2) {
          final hasTrailing = index + 1 < children.length;
          rows.add(
            Padding(
              padding: EdgeInsets.only(
                bottom: index + 2 < children.length ? 12 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: children[index]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: hasTrailing ? children[index + 1] : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }

  Widget _buildModernTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = controller.text.trim().isNotEmpty;
    final showInlineLabel = !hasValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasValue) _buildFieldHeading(context, label),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          minLines: maxLines > 1 ? maxLines : 1,
          maxLines: maxLines,
          style: TextStyle(
            color: _textPrimaryColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: _inputDecoration(
            context,
            label: showInlineLabel ? label : null,
            hint: showInlineLabel ? null : hint,
            icon: icon,
          ),
        ),
      ],
    );
  }

  Widget _courseDropdown(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final selectedCourse = _selectedCourse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFieldHeading(context, l10n.course),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          key: ValueKey<int?>(_courseId),
          initialValue: _courseId,
          isExpanded: true,
          decoration: _inputDecoration(
            context,
            hint: l10n.instructorAssignmentCourseHint,
            icon: Icons.school_outlined,
          ),
          borderRadius: BorderRadius.circular(18),
          items: widget.courses
              .map(
                (course) => DropdownMenuItem<int>(
                  value: course.courseId,
                  child: Text(
                    '${course.course.code} - ${course.course.name}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: _textPrimaryColor(isDark),
                      fontSize: responsive.isMobile ? 13 : 14,
                    ),
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (BuildContext context) {
            return widget.courses.map((course) {
              final isSelected = selectedCourse?.courseId == course.courseId;
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${course.course.code} - ${course.course.name}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: _textPrimaryColor(isDark),
                    fontSize: responsive.isMobile ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          onChanged: (value) => setState(() => _courseId = value),
          validator: (value) {
            if (value == null) {
              return l10n.instructorAssignmentValidationCourseRequired;
            }
            return null;
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _selectionDropdown<T>(
    BuildContext context, {
    required bool isDark,
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFieldHeading(context, label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey<T>(value),
          initialValue: value,
          isExpanded: true,
          decoration: _inputDecoration(context, hint: label, icon: icon),
          borderRadius: BorderRadius.circular(18),
          items: items,
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldHeading(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        label,
        style: TextStyle(
          color: _textSecondaryColor(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    String? label,
    String? hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _borderColor(isDark);

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      alignLabelWithHint: false,
      floatingLabelBehavior: label == null
          ? FloatingLabelBehavior.never
          : FloatingLabelBehavior.auto,
      fillColor: isDark
          ? _darkSurfaceColor().withValues(alpha: 0.65)
          : Colors.white,
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
      hintStyle: TextStyle(
        color: _textTertiaryColor(isDark),
        fontWeight: FontWeight.w500,
      ),
      labelStyle: TextStyle(
        color: _textSecondaryColor(isDark),
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      enabledBorder: border(borderColor),
      focusedBorder: border(_primaryColor),
      errorBorder: border(CreateAssignmentColors.error),
      focusedErrorBorder: border(CreateAssignmentColors.error),
    );
  }

  Widget _dateButton(
    BuildContext context, {
    required bool isDark,
    required DateTime? dateValue,
    required DateTime defaultDate,
    required ValueChanged<DateTime> onChanged,
    required Color accentColor,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = dateValue == null
        ? AppLocalizations.of(context).dueDate
        : DateFormat.yMMMd(locale).format(dateValue);
    final now = DateTime.now();
    final firstDate = _earlierDate(dateValue, now);

    return _timeDateButton(
      context,
      isDark: isDark,
      accentColor: accentColor,
      icon: Icons.calendar_today_rounded,
      label: dateLabel,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          initialDate: dateValue ?? defaultDate,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }

  Widget _timeButton(
    BuildContext context, {
    required bool isDark,
    required TimeOfDay? timeValue,
    required ValueChanged<TimeOfDay> onChanged,
    required Color accentColor,
  }) {
    final timeLabel = timeValue == null
        ? AppLocalizations.of(context).schedule
        : timeValue.format(context);

    return _timeDateButton(
      context,
      isDark: isDark,
      accentColor: accentColor,
      icon: Icons.access_time_rounded,
      label: timeLabel,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: timeValue ?? const TimeOfDay(hour: 23, minute: 59),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }

  Widget _timeDateButton(
    BuildContext context, {
    required bool isDark,
    required Color accentColor,
    required IconData icon,
    required String label,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark
              ? _darkCardColor()
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textPrimaryColor(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedTypes(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.instructorAssignmentQuickTypes,
          style: TextStyle(
            color: _textSecondaryColor(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedTypes.map((type) {
            final isSelected = _parsedAllowedTypes.contains(type);
            return FilterChip(
              selected: isSelected,
              onSelected: (_) => _toggleSuggestedType(type),
              label: Text(type.toUpperCase()),
              avatar: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
              ),
              side: BorderSide(
                color: isSelected
                    ? _primaryColor.withValues(alpha: 0.22)
                    : _borderColor(isDark),
              ),
              backgroundColor: isDark ? _darkCardColor() : Colors.white,
              selectedColor: _primaryColor.withValues(alpha: 0.10),
              labelStyle: TextStyle(
                color: isSelected ? _primaryColor : _textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required bool isDark,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.attach_file_rounded, size: 16, color: _primaryColor),
          const SizedBox(width: 6),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _removeAllowedType(value),
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: _textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTemplates(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final templates = <_InstructionTemplate>[
      _InstructionTemplate(
        label: l10n.instructorAssignmentTemplateChecklist,
        icon: Icons.checklist_rounded,
        value: '- Step 1\n- Step 2\n- Step 3',
      ),
      _InstructionTemplate(
        label: l10n.instructorAssignmentTemplateCode,
        icon: Icons.code_rounded,
        value: '```\nExample solution notes\n```',
      ),
      _InstructionTemplate(
        label: l10n.instructorAssignmentTemplateRubric,
        icon: Icons.rule_folder_outlined,
        value: '### Rubric\n- Accuracy\n- Structure\n- Delivery',
      ),
      _InstructionTemplate(
        label: l10n.instructorAssignmentTemplateReminder,
        icon: Icons.campaign_outlined,
        value: '> Remember to name your files clearly before submitting.',
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: templates.map((template) {
        return ActionChip(
          onPressed: () => _appendInstructionTemplate(template.value),
          avatar: Icon(template.icon, size: 16, color: _warningColor),
          backgroundColor: isDark
              ? _darkCardColor()
              : _warningLightColor.withValues(alpha: 0.35),
          side: BorderSide(color: _warningColor.withValues(alpha: 0.16)),
          label: Text(
            template.label,
            style: TextStyle(
              color: _textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploaderContainer(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? _darkSurfaceColor().withValues(alpha: 0.55)
            : _warningColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _warningColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _warningColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.cloud_upload_outlined, color: _warningColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.assignmentInstructionFiles,
                      style: TextStyle(
                        color: _textPrimaryColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.instructorAssignmentResourcesHint,
                      style: TextStyle(
                        color: _textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InstructionFileUploader(
            key: _uploaderKey,
            assignmentId: widget.assignmentId ?? 0,
            assignmentService: widget.assignmentService,
            initialFiles: _uploadedInstructionFiles,
            useTAColors: widget.useTAColors,
            onFilesChanged: (files) => _uploadedInstructionFiles = files,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? _darkCardColor().withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.instructorAssignmentReadyToSave,
              style: TextStyle(
                color: _textPrimaryColor(isDark),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _statusHelperText(l10n, _status),
              style: TextStyle(color: _textSecondaryColor(isDark), height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _assignmentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: widget.submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  widget.submitting
                      ? l10n.instructorAssignmentSavingAction
                      : l10n.instructorAssignmentSaveAction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSuggestedType(String type) {
    final updated = _parsedAllowedTypes.toSet();
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    _allowedTypesController.text = updated.join(', ');
    _allowedTypesController.selection = TextSelection.collapsed(
      offset: _allowedTypesController.text.length,
    );
  }

  void _removeAllowedType(String type) {
    final updated = _parsedAllowedTypes.toSet()..remove(type);
    _allowedTypesController.text = updated.join(', ');
    _allowedTypesController.selection = TextSelection.collapsed(
      offset: _allowedTypesController.text.length,
    );
  }

  void _appendInstructionTemplate(String value) {
    final existing = _instructionsController.text.trimRight();
    final next = existing.isEmpty ? value : '$existing\n\n$value';
    _instructionsController.text = next;
    _instructionsController.selection = TextSelection.collapsed(
      offset: next.length,
    );
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return AppLocalizations.of(
        context,
      ).instructorAssignmentValidationPositiveNumber;
    }
    return null;
  }

  String? _validatePositiveInt(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return AppLocalizations.of(
        context,
      ).instructorAssignmentValidationPositiveInteger;
    }
    return null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.instructorAssignmentValidationDueRequired)),
      );
      return;
    }
    if (_availableFromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.instructorAssignmentValidationAvailableRequired),
        ),
      );
      return;
    }

    final availableFromTime =
        _availableFromTime ?? TimeOfDay.fromDateTime(_availableFromDate!);
    final availableFromDateTime = _combineDateAndTime(
      _availableFromDate!,
      availableFromTime,
    );
    final dueTime = _dueTime ?? const TimeOfDay(hour: 23, minute: 59);
    final dueDateTime = _combineDateAndTime(_dueDate!, dueTime);

    if (!dueDateTime.isAfter(availableFromDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.instructorAssignmentValidationDueAfterAvailable),
        ),
      );
      return;
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
        availableFrom: availableFromDateTime.toUtc(),
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

  String _submissionTypeLabel(AppLocalizations l10n, api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return l10n.assignmentSubmissionTypeFile;
      case api.SubmissionType.text:
        return l10n.assignmentSubmissionTypeText;
      case api.SubmissionType.link:
        return l10n.assignmentSubmissionTypeLink;
      case api.SubmissionType.multiple:
        return l10n.assignmentSubmissionTypeMultiple;
      case api.SubmissionType.unknown:
        return l10n.unknown;
    }
  }

  String _statusLabel(AppLocalizations l10n, api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return l10n.draft;
      case api.AssignmentStatus.published:
        return l10n.assignmentStatusPublished;
      case api.AssignmentStatus.closed:
        return l10n.assignmentStatusClosed;
      case api.AssignmentStatus.archived:
        return l10n.archived;
      case api.AssignmentStatus.unknown:
        return l10n.unknown;
    }
  }

  String _statusHelperText(AppLocalizations l10n, api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return l10n.instructorAssignmentDraftStateHelper;
      case api.AssignmentStatus.published:
        return l10n.instructorAssignmentPublishedStateHelper;
      case api.AssignmentStatus.closed:
        return l10n.instructorAssignmentClosedStateHelper;
      case api.AssignmentStatus.archived:
        return l10n.instructorAssignmentArchivedStateHelper;
      case api.AssignmentStatus.unknown:
        return l10n.instructorAssignmentDraftStateHelper;
    }
  }

  static DateTime _earlierDate(DateTime? first, DateTime second) {
    if (first == null) {
      return second;
    }
    return first.isBefore(second) ? first : second;
  }

  static DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    final normalized = date.isUtc ? date.toLocal() : date;
    return DateTime(
      normalized.year,
      normalized.month,
      normalized.day,
      time.hour,
      time.minute,
    );
  }
}

class _InstructionTemplate {
  const _InstructionTemplate({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;
}
