import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/lab_instruction_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../services/api/lab_service.dart';
import '../../ta/shared/ta_colors.dart';
import '../shared/instructor_colors.dart';
import 'lab_editor_instruction_file_uploader.dart';

enum LabComposerRole { instructor, ta }

class LabCreateForm extends StatefulWidget {
  const LabCreateForm({
    super.key,
    required this.courses,
    required this.labService,
    required this.onSubmit,
    this.existingLab,
    this.activeLab,
    this.submitting = false,
    this.role = LabComposerRole.instructor,
  });

  final List<TeachingCourseModel> courses;
  final LabService labService;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final LabModel? existingLab;
  final LabModel? activeLab;
  final bool submitting;
  final LabComposerRole role;

  @override
  State<LabCreateForm> createState() => LabCreateFormState();
}

class LabCreateFormState extends State<LabCreateForm> {
  static const List<String> _supportedTypes = <String>[
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
  ];

  final _formKey = GlobalKey<FormState>();
  final _uploaderKey = GlobalKey<LabEditorInstructionFileUploaderState>();

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
  List<DriveFileModel> _uploadedInstructionFiles = <DriveFileModel>[];
  List<LabInstructionModel> _uploadedInstructions = <LabInstructionModel>[];

  bool get _isTA => widget.role == LabComposerRole.ta;

  Color get _primary => _isTA ? TAColors.primary : InstructorColors.primary;
  Color get _accent => _isTA ? TAColors.secondary : InstructorColors.info;
  Color get _warning => _isTA ? TAColors.warning : InstructorColors.warning;
  Color get _warningLight =>
      _isTA ? TAColors.warningLight : InstructorColors.warningLight;
  Color get _error => _isTA ? TAColors.error : InstructorColors.error;

  LinearGradient get _headerGradient =>
      _isTA ? TAColors.headerGradient : InstructorColors.headerGradient;

  Color _scaffold(bool isDark) => _isTA
      ? TAColors.scaffoldColor(isDark)
      : InstructorColors.background(isDark);
  Color _card(bool isDark) =>
      _isTA ? TAColors.cardColor(isDark) : InstructorColors.cardColor(isDark);
  Color _surface(bool isDark) => _isTA
      ? TAColors.surfaceColor(isDark)
      : InstructorColors.surfaceColor(isDark);
  Color _border(bool isDark) => _isTA
      ? TAColors.borderColor(isDark)
      : InstructorColors.borderColor(isDark);
  Color _textPrimary(bool isDark) => _isTA
      ? TAColors.textPrimaryColor(isDark)
      : InstructorColors.textPrimaryColor(isDark);
  Color _textSecondary(bool isDark) => _isTA
      ? TAColors.textSecondaryColor(isDark)
      : InstructorColors.textSecondaryColor(isDark);
  Color _textTertiary(bool isDark) => _isTA
      ? TAColors.textTertiaryColor(isDark)
      : InstructorColors.textTertiaryColor(isDark);

  @override
  void initState() {
    super.initState();
    final initial = widget.existingLab;

    _titleController = TextEditingController(text: initial?.title ?? '')
      ..addListener(_refreshView);
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    )..addListener(_refreshView);
    _maxScoreController = TextEditingController(
      text: (initial?.maxScore ?? 100).toString(),
    )..addListener(_refreshView);
    _weightController = TextEditingController(
      text: (initial?.weight ?? 10).toString(),
    )..addListener(_refreshView);
    _allowedFileTypesController = TextEditingController(
      text: initial?.allowedFileTypes ?? '',
    )..addListener(_refreshView);
    _maxFileSizeController = TextEditingController(
      text: initial?.maxFileSizeMb?.toString() ?? '',
    )..addListener(_refreshView);
    _uploadedInstructionFiles = List<DriveFileModel>.from(
      initial?.instructionFiles ?? const <DriveFileModel>[],
    );
    _uploadedInstructions = List<LabInstructionModel>.from(
      initial?.instructions ?? const <LabInstructionModel>[],
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

  int get _effectiveLabId =>
      widget.activeLab?.labId ??
      widget.existingLab?.labId ??
      int.tryParse(widget.activeLab?.id ?? widget.existingLab?.id ?? '') ??
      0;

  Future<PendingLabInstructionUploadResult> uploadPendingInstructionFiles(
    int labId,
  ) async {
    final uploaderState = _uploaderKey.currentState;
    if (uploaderState == null) {
      return const PendingLabInstructionUploadResult();
    }
    return uploaderState.uploadPendingFiles(labId);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_refreshView)
      ..dispose();
    _descriptionController
      ..removeListener(_refreshView)
      ..dispose();
    _maxScoreController
      ..removeListener(_refreshView)
      ..dispose();
    _weightController
      ..removeListener(_refreshView)
      ..dispose();
    _allowedFileTypesController
      ..removeListener(_refreshView)
      ..dispose();
    _maxFileSizeController
      ..removeListener(_refreshView)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LabCreateForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextActiveLab = widget.activeLab;
    if (nextActiveLab != null && nextActiveLab != oldWidget.activeLab) {
      _uploadedInstructionFiles = List<DriveFileModel>.from(
        nextActiveLab.instructionFiles,
      );
      _uploadedInstructions = List<LabInstructionModel>.from(
        nextActiveLab.instructions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.existingLab != null;
    final dueInPast = _dueDate != null && _dueDate!.isBefore(DateTime.now());
    final maxScoreLowered =
        isEdit &&
        widget.existingLab != null &&
        (double.tryParse(_maxScoreController.text.trim()) ??
                widget.existingLab!.maxScore) <
            widget.existingLab!.maxScore;

    return Container(
      color: _scaffold(isDark),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _buildHeroCard(context, l10n, isDark),
            const SizedBox(height: 18),
            _LabSectionCard(
              isDark: isDark,
              accentColor: _primary,
              title: l10n.labEditorCoreSection,
              subtitle: l10n.labEditorCoreSectionSubtitle,
              icon: Icons.grid_view_rounded,
              child: Column(
                children: <Widget>[
                  _buildModernTextField(
                    context,
                    controller: _titleController,
                    label: l10n.title,
                    hint: l10n.labEditorTitleHint,
                    icon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.labEditorValidationTitleRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCourseDropdown(context, l10n, isDark),
                  const SizedBox(height: 12),
                  _buildModernTextField(
                    context,
                    controller: _descriptionController,
                    label: l10n.description,
                    hint: l10n.labEditorDescriptionHint,
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            _LabSectionCard(
              isDark: isDark,
              accentColor: _accent,
              title: l10n.labEditorScheduleSection,
              subtitle: l10n.labEditorScheduleSectionSubtitle,
              icon: Icons.event_available_rounded,
              child: Column(
                children: <Widget>[
                  _buildScheduleCard(
                    context,
                    isDark: isDark,
                    title: l10n.availableFrom,
                    subtitle: l10n.labEditorAvailableHelper,
                    value: _availableFrom,
                    onChanged: (value) =>
                        setState(() => _availableFrom = value),
                    accentColor: _primary,
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleCard(
                    context,
                    isDark: isDark,
                    title: l10n.dueDate,
                    subtitle: l10n.labEditorDueHelper,
                    value: _dueDate,
                    onChanged: (value) => setState(() => _dueDate = value),
                    accentColor: _warning,
                  ),
                  if (dueInPast) ...<Widget>[
                    const SizedBox(height: 12),
                    _buildWarningBanner(
                      isDark: isDark,
                      message: l10n.labEditorPastDueWarning,
                    ),
                  ],
                ],
              ),
            ),
            _LabSectionCard(
              isDark: isDark,
              accentColor: _warning,
              title: l10n.labEditorRulesSection,
              subtitle: l10n.labEditorRulesSectionSubtitle,
              icon: Icons.tune_rounded,
              child: Column(
                children: <Widget>[
                  _buildResponsiveFields(<Widget>[
                    _buildModernTextField(
                      context,
                      controller: _maxScoreController,
                      label: l10n.taLabMaxScore,
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
                      label: l10n.labEditorWeight,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return null;
                        }
                        return _validatePositiveNumber(value);
                      },
                    ),
                    _buildStatusDropdown(context, l10n, isDark),
                  ]),
                  if (maxScoreLowered) ...<Widget>[
                    const SizedBox(height: 12),
                    _buildWarningBanner(
                      isDark: isDark,
                      message: l10n.labEditorMaxScoreWarning,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildModernTextField(
                    context,
                    controller: _allowedFileTypesController,
                    label: l10n.assignmentAllowedFileTypes,
                    hint: l10n.labEditorAllowedTypesHint,
                    icon: Icons.attach_file_rounded,
                    validator: _validateAllowedFileTypes,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  _buildSuggestedTypes(context, l10n, isDark),
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
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _LabSectionCard(
              isDark: isDark,
              accentColor: _primary,
              title: l10n.labEditorInstructionSection,
              subtitle: l10n.labEditorInstructionSectionSubtitle,
              icon: Icons.attach_file_rounded,
              child: LabEditorInstructionFileUploader(
                key: _uploaderKey,
                labId: _effectiveLabId,
                labService: widget.labService,
                initialFiles: _uploadedInstructionFiles,
                initialInstructions: _uploadedInstructions,
                useTAColors: _isTA,
                onFilesChanged: (files) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _uploadedInstructionFiles = List<DriveFileModel>.from(files);
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildSaveCard(context, l10n, isDark, isEdit: isEdit),
          ],
        ),
      ),
    );
  }

  List<String> get _parsedAllowedTypes => _allowedFileTypesController.text
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
        ? l10n.labEditorHeroTitle
        : _titleController.text.trim();
    final dueLabel = _dueDate == null
        ? l10n.assignmentNoDueDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_jm().format(_dueDate!.toLocal());

    return Container(
      decoration: BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _primary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -26,
            right: -10,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -36,
            left: -14,
            child: Container(
              width: 150,
              height: 150,
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
                        Icons.science_outlined,
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
                            _isTA
                                ? l10n.taLabEditorHeroSubtitle
                                : l10n.instructorLabEditorHeroSubtitle,
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
                      label: l10n.course,
                      value: selectedCourse == null
                          ? l10n.noCoursesAvailable
                          : selectedCourse.course.code,
                      icon: Icons.school_outlined,
                    ),
                    _buildHeroMetric(
                      label: l10n.labEditorVisibility,
                      value: _statusLabel(l10n, _status),
                      icon: Icons.visibility_outlined,
                    ),
                    _buildHeroMetric(
                      label: l10n.taLabMaxScore,
                      value: _maxScoreController.text.trim().isEmpty
                          ? '100'
                          : _maxScoreController.text.trim(),
                      icon: Icons.star_border_rounded,
                    ),
                    _buildHeroMetric(
                      label: l10n.dueDate,
                      value: dueLabel,
                      icon: Icons.event_available_rounded,
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

  Widget _buildHeroMetric({
    required String label,
    required String value,
    required IconData icon,
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
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? _surface(isDark).withValues(alpha: 0.55)
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
              color: _textPrimary(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _textSecondary(isDark),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _buildDateButton(
            context,
            isDark: isDark,
            value: value,
            accentColor: accentColor,
            onChanged: onChanged,
          ),
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
                .toList(growable: false),
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
            color: _textPrimary(isDark),
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

  Widget _buildCourseDropdown(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
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
            hint: l10n.labEditorCourseHint,
            icon: Icons.school_outlined,
          ),
          borderRadius: BorderRadius.circular(18),
          items: widget.courses
              .map(
                (course) => DropdownMenuItem<int>(
                  value: course.courseId,
                  child: Text(
                    '${course.course.code} - ${course.course.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _textPrimary(isDark),
                      fontSize: 13.5,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          selectedItemBuilder: (BuildContext context) {
            return widget.courses
                .map((course) {
                  final isSelected =
                      selectedCourse?.courseId == course.courseId;
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${course.course.code} - ${course.course.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontSize: 13.5,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  );
                })
                .toList(growable: false);
          },
          onChanged: (value) => setState(() => _courseId = value),
          validator: (value) {
            if (value == null) {
              return l10n.labEditorValidationCourseRequired;
            }
            return null;
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFieldHeading(context, l10n.labEditorVisibility),
        const SizedBox(height: 8),
        DropdownButtonFormField<api.LabStatus>(
          key: ValueKey<api.LabStatus>(_status),
          initialValue: _status,
          isExpanded: true,
          decoration: _inputDecoration(
            context,
            hint: l10n.labEditorVisibility,
            icon: Icons.visibility_outlined,
          ),
          borderRadius: BorderRadius.circular(18),
          items:
              const <api.LabStatus>[
                    api.LabStatus.draft,
                    api.LabStatus.published,
                  ]
                  .map(
                    (status) => DropdownMenuItem<api.LabStatus>(
                      value: status,
                      child: Text(_statusLabel(l10n, status)),
                    ),
                  )
                  .toList(growable: false),
          onChanged: (value) {
            if (value != null) {
              setState(() => _status = value);
            }
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldHeading(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: _textSecondary(isDark),
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
    final borderColor = _border(isDark);

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
          ? _surface(isDark).withValues(alpha: 0.65)
          : Colors.white,
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
      hintStyle: TextStyle(
        color: _textTertiary(isDark),
        fontWeight: FontWeight.w500,
      ),
      labelStyle: TextStyle(
        color: _textSecondary(isDark),
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      enabledBorder: border(borderColor),
      focusedBorder: border(_primary),
      errorBorder: border(_error),
      focusedErrorBorder: border(_error),
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required bool isDark,
    required DateTime? value,
    required Color accentColor,
    required ValueChanged<DateTime> onChanged,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = value == null
        ? AppLocalizations.of(context).dueDate
        : DateFormat.yMMMd(locale).add_jm().format(value.toLocal());

    return InkWell(
      onTap: () async {
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
        if (!context.mounted) {
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
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? _card(isDark) : Colors.white.withValues(alpha: 0.92),
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
              child: Icon(Icons.event_rounded, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _textSecondary(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedTypes(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.labEditorQuickTypes,
          style: TextStyle(
            color: _textSecondary(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _supportedTypes
              .map((type) {
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
                        ? _primary.withValues(alpha: 0.22)
                        : _border(isDark),
                  ),
                  backgroundColor: isDark ? _card(isDark) : Colors.white,
                  selectedColor: _primary.withValues(alpha: 0.10),
                  labelStyle: TextStyle(
                    color: isSelected ? _primary : _textSecondary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                );
              })
              .toList(growable: false),
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
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.attach_file_rounded, size: 16, color: _primary),
          const SizedBox(width: 6),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              color: _primary,
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
              color: _textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner({required bool isDark, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _warningLight.withValues(alpha: isDark ? 0.14 : 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: _warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _textPrimary(isDark),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark, {
    required bool isEdit,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? _card(isDark).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primary.withValues(alpha: 0.10)),
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
              l10n.labEditorReadyToSave,
              style: TextStyle(
                color: _textPrimary(isDark),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _statusHelperText(l10n, _status),
              style: TextStyle(color: _textSecondary(isDark), height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
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
                      ? l10n.labEditorSavingAction
                      : isEdit
                      ? l10n.labEditorSaveAction
                      : l10n.labEditorCreateAction,
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
    _allowedFileTypesController.text = updated.join(', ');
    _allowedFileTypesController.selection = TextSelection.collapsed(
      offset: _allowedFileTypesController.text.length,
    );
  }

  void _removeAllowedType(String type) {
    final updated = _parsedAllowedTypes.toSet()..remove(type);
    _allowedFileTypesController.text = updated.join(', ');
    _allowedFileTypesController.selection = TextSelection.collapsed(
      offset: _allowedFileTypesController.text.length,
    );
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return AppLocalizations.of(context).labEditorValidationPositiveNumber;
    }
    return null;
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
      return AppLocalizations.of(
        context,
      ).labEditorValidationUnsupportedTypes(unknownTypes.join(', '));
    }

    return null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labEditorValidationCourseRequired)),
      );
      return;
    }
    if (_availableFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labEditorValidationAvailableRequired)),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labEditorValidationDueRequired)),
      );
      return;
    }
    if (!_dueDate!.isAfter(_availableFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labEditorValidationDueAfterAvailable)),
      );
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

  String _statusLabel(AppLocalizations l10n, api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return l10n.assignmentStatusPublished;
      case api.LabStatus.draft:
      case api.LabStatus.unknown:
      case api.LabStatus.closed:
      case api.LabStatus.archived:
        return l10n.draft;
    }
  }

  String _statusHelperText(AppLocalizations l10n, api.LabStatus status) {
    return status == api.LabStatus.published
        ? l10n.labEditorPublishedStateHelper
        : l10n.labEditorDraftStateHelper;
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

class _LabSectionCard extends StatefulWidget {
  const _LabSectionCard({
    required this.isDark,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final bool isDark;
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  State<_LabSectionCard> createState() => _LabSectionCardState();
}

class _LabSectionCardState extends State<_LabSectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
    _iconTurns = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = widget.isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = widget.isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark
        ? const Color(0xFF475569)
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _expanded
              ? widget.accentColor.withValues(alpha: 0.24)
              : borderColor,
        ),
        boxShadow: widget.isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: widget.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (BuildContext context, Widget? child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}
