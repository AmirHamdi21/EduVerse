import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/exams/exam_export_options_model.dart';
import '../../../models/exams/exam_full_detail_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_paper_template_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../widgets/instructor/question_bank/question_form_menu_field.dart';
import '../../../widgets/instructor/question_bank/question_text_renderer.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class ExamPaperExportPreviewScreen extends StatefulWidget {
  const ExamPaperExportPreviewScreen({super.key, required this.examId});

  final int examId;

  @override
  State<ExamPaperExportPreviewScreen> createState() =>
      _ExamPaperExportPreviewScreenState();
}

class _ExamPaperExportPreviewScreenState
    extends State<ExamPaperExportPreviewScreen> {
  late final ExamGeneratorService _service = ExamGeneratorService(
    coreApiClient: CoreApiClient(),
  );

  final _templateName = TextEditingController();
  final _left1 = TextEditingController();
  final _left2 = TextEditingController();
  final _left3 = TextEditingController();
  final _center1 = TextEditingController();
  final _center2 = TextEditingController();
  final _right1 = TextEditingController();
  final _right2 = TextEditingController();
  final _right3 = TextEditingController();
  final _metaLeft1 = TextEditingController();
  final _metaLeft2 = TextEditingController();
  final _metaLeft3 = TextEditingController();
  final _metaRight1 = TextEditingController();
  final _metaRight2 = TextEditingController();
  final _metaRight3 = TextEditingController();
  final _endLine = TextEditingController();
  final _goodLuck = TextEditingController();
  final _examiners = TextEditingController();
  final _pageNumber = TextEditingController();
  final _freeText = TextEditingController();

  ExamFullDetailModel? _detail;
  List<ExamPaperTemplateModel> _templates = const <ExamPaperTemplateModel>[];
  ExamPaperTemplateModel? _currentTemplate;
  bool _loading = true;
  bool _working = false;
  String? _error;
  ExamExportVariant _variant = ExamExportVariant.student;
  ExamExportFormat _format = ExamExportFormat.pdf;
  final ExamAnswerKeyStyle _answerKeyStyle = ExamAnswerKeyStyle.inline;
  bool _studentNameLine = true;
  bool _showCourseCode = true;
  bool _showInstructorName = false;
  bool _showTotalMarks = true;
  bool _showQuestionMarks = true;
  bool _pageBreakPerSection = false;
  ExamPaperLayoutMode _layoutMode = ExamPaperLayoutMode.hybrid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _templateName,
      _left1,
      _left2,
      _left3,
      _center1,
      _center2,
      _right1,
      _right2,
      _right3,
      _metaLeft1,
      _metaLeft2,
      _metaLeft3,
      _metaRight1,
      _metaRight2,
      _metaRight3,
      _endLine,
      _goodLuck,
      _examiners,
      _pageNumber,
      _freeText,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final detailResult = await _service.getFullExam(widget.examId);
    final detail = detailResult.data;
    if (detail == null) {
      if (!mounted) return;
      setState(() {
        _error = detailResult.error?.message;
        _loading = false;
      });
      return;
    }
    final templateResult = await _service.getPaperTemplates(
      courseId: detail.exam.courseId,
    );
    final saved = detail.paperTemplateSnapshot == null
        ? null
        : ExamPaperTemplateModel.fromJson(detail.paperTemplateSnapshot!);
    final fallback = ExamPaperTemplateModel.alexandriaDefault(
      courseId: detail.exam.courseId,
      courseCode: detail.courseCode,
      courseName: detail.courseName,
      durationMinutes: detail.durationMinutes,
    );
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _templates = templateResult.data ?? const <ExamPaperTemplateModel>[];
      _currentTemplate = saved ?? fallback;
      _layoutMode = _currentTemplate!.layoutMode;
      _loading = false;
    });
    _hydrateControllers(_currentTemplate!);
  }

  void _hydrateControllers(ExamPaperTemplateModel template) {
    final l10n = AppLocalizations.of(context);
    _templateName.text = template.name;
    final header = template.headerJson;
    final trailing = template.trailingJson;
    _setZone([_left1, _left2, _left3], header['left']);
    _setZone([_center1, _center2], header['center']);
    _setZone([_right1, _right2, _right3], header['right']);
    _setZone([_metaLeft1, _metaLeft2, _metaLeft3], header['metadataLeft']);
    _setZone([_metaRight1, _metaRight2, _metaRight3], header['metadataRight']);
    final lines = _list(trailing['lines']);
    _endLine.text = _valueAt(lines, 0, l10n.examPaperDefaultEndLine);
    _goodLuck.text = _valueAt(lines, 1, l10n.examPaperDefaultGoodLuckLine);
    _examiners.text =
        trailing['examiners']?.toString() ?? l10n.examPaperDefaultExaminersLine;
    _pageNumber.text =
        template.footerJson['pageNumberFormat']?.toString() ??
        l10n.examPaperDefaultPageNumberFormat('{page}', '{totalPages}');
  }

  void _setZone(List<TextEditingController> controllers, dynamic raw) {
    final values = _list(raw);
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].text = _valueAt(values, i, '');
    }
  }

  String _valueAt(List<dynamic> values, int index, String fallback) {
    if (index >= values.length) return fallback;
    final value = values[index];
    if (value is Map) return value['value']?.toString() ?? fallback;
    return value?.toString() ?? fallback;
  }

  ExamPaperTemplateModel _buildTemplate() {
    final base =
        _currentTemplate ??
        ExamPaperTemplateModel.alexandriaDefault(
          courseId: _detail?.exam.courseId,
          courseCode: _detail?.courseCode,
          courseName: _detail?.courseName,
          durationMinutes: _detail?.durationMinutes,
        );
    final l10n = AppLocalizations.of(context);
    return base.copyWith(
      name: _templateName.text.trim().isEmpty
          ? l10n.examPaperDefaultTemplateName
          : _templateName.text.trim(),
      layoutMode: _layoutMode,
      headerJson: <String, dynamic>{
        'left': _zone([_left1, _left2, _left3], boldFirst: true),
        'center': _zone([_center1, _center2]),
        'right': _zone([_right1, _right2, _right3], boldFirst: true),
        'metadataLeft': _zone([_metaLeft1, _metaLeft2, _metaLeft3]),
        'metadataRight': _zone([_metaRight1, _metaRight2, _metaRight3]),
        'freeElements': _list(base.headerJson['freeElements']),
      },
      trailingJson: <String, dynamic>{
        'lines': <Map<String, dynamic>>[
          {'value': _endLine.text},
          {'value': _goodLuck.text},
        ],
        'examiners': _examiners.text,
      },
      footerJson: <String, dynamic>{'pageNumberFormat': _pageNumber.text},
    );
  }

  List<Map<String, dynamic>> _zone(
    List<TextEditingController> controllers, {
    bool boldFirst = false,
  }) {
    return [
      for (var i = 0; i < controllers.length; i++)
        if (controllers[i].text.trim().isNotEmpty)
          <String, dynamic>{
            'value': controllers[i].text.trim(),
            if (boldFirst && i < 2) 'bold': true,
          },
    ];
  }

  void _refreshTemplate() {
    setState(() => _currentTemplate = _buildTemplate());
  }

  void _addFreeElement() {
    final text = _freeText.text.trim();
    if (text.isEmpty) return;
    final template = _buildTemplate();
    final header = Map<String, dynamic>.from(template.headerJson);
    final elements = _list(
      header['freeElements'],
    ).map((item) => Map<String, dynamic>.from(item as Map)).toList();
    elements.add(<String, dynamic>{
      'value': text,
      'x': 80,
      'y': 20,
      'fontSize': 10,
      'align': 'center',
    });
    header['freeElements'] = elements;
    _freeText.clear();
    setState(() => _currentTemplate = template.copyWith(headerJson: header));
  }

  void _moveFreeElement(int index, Offset delta, Size previewSize) {
    final template = _buildTemplate();
    final header = Map<String, dynamic>.from(template.headerJson);
    final elements = _list(
      header['freeElements'],
    ).map((item) => Map<String, dynamic>.from(item as Map)).toList();
    if (index >= elements.length) return;
    final mmX = delta.dx / previewSize.width * 210;
    final mmY = delta.dy / previewSize.height * 297;
    final item = elements[index];
    item['x'] = ((num.tryParse(item['x']?.toString() ?? '') ?? 0) + mmX).clamp(
      0,
      190,
    );
    item['y'] = ((num.tryParse(item['y']?.toString() ?? '') ?? 0) + mmY).clamp(
      0,
      80,
    );
    header['freeElements'] = elements;
    setState(() => _currentTemplate = template.copyWith(headerJson: header));
  }

  Future<void> _saveTemplate({required bool saveAsNew}) async {
    setState(() => _working = true);
    final template = _buildTemplate().copyWith(clearId: saveAsNew);
    final result = saveAsNew || _currentTemplate?.id == null
        ? await _service.createPaperTemplate(template)
        : await _service.updatePaperTemplate(template);
    if (!mounted) return;
    setState(() => _working = false);
    if (result.data != null) {
      setState(() => _currentTemplate = result.data);
      await _load();
    }
    if (!mounted) return;
    _snack(
      result.error?.message ??
          AppLocalizations.of(context).examPaperTemplateSaved,
    );
  }

  void _resetDefaultTemplate() {
    final detail = _detail;
    if (detail == null) return;
    final template = ExamPaperTemplateModel.alexandriaDefault(
      courseId: detail.exam.courseId,
      courseCode: detail.courseCode,
      courseName: detail.courseName,
      durationMinutes: detail.durationMinutes,
    );
    setState(() {
      _currentTemplate = template;
      _layoutMode = template.layoutMode;
    });
    _hydrateControllers(template);
  }

  Future<void> _applyTemplate() async {
    final template = _buildTemplate();
    setState(() => _working = true);
    final result = await _service.applyPaperTemplate(
      examId: widget.examId,
      template: template,
    );
    if (!mounted) return;
    setState(() => _working = false);
    _snack(
      result.error?.message ??
          AppLocalizations.of(context).examPaperTemplateApplied,
    );
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final template = _buildTemplate();
    setState(() => _working = true);
    await _service.applyPaperTemplate(
      examId: widget.examId,
      template: template,
    );
    final result = await _service.exportExam(
      examId: widget.examId,
      options: ExamExportOptionsModel(
        format: _format,
        variant: _variant,
        studentNameLine: _studentNameLine,
        showCourseCode: _showCourseCode,
        pageBreakPerSection: _pageBreakPerSection,
        showInstructorName: _showInstructorName,
        showTotalMarks: _showTotalMarks,
        showQuestionMarks: _showQuestionMarks,
        answerKeyStyle: _answerKeyStyle,
        paperTemplateId: template.id,
        paperTemplateSnapshot: template.toSnapshot(),
      ),
    );
    String? filePath;
    if (result.data != null) {
      final save = await _service.saveExportFile(result.data!);
      filePath = save.data;
    }
    if (!mounted) return;
    setState(() => _working = false);
    if (filePath == null) {
      _snack(result.error?.message ?? l10n.examPaperExportFailed);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.examPaperExportReady),
        content: Text(l10n.examPaperExportReadyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.done),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await Share.shareXFiles([XFile(filePath!)]);
            },
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l10n.examPaperShareFile),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _service.openExportFile(filePath!);
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.examPaperOpenFile),
          ),
        ],
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canShowActions = !_loading && _error == null && _detail != null;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => safeFeatureBack(
            context,
            '/instructor/exam-generator/exams/${widget.examId}',
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(l10n.examPaperDesignerTitle),
        actions: [
          if (canShowActions)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: IconButton.filledTonal(
                tooltip: l10n.examPaperApplyToExam,
                onPressed: _working ? null : _applyTemplate,
                icon: _working
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
              ),
            ),
        ],
      ),
      bottomNavigationBar: canShowActions
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _bottomBar(context),
            )
          : null,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 4),
            )
          : _error != null || _detail == null
          ? Center(
              child: FilledButton(onPressed: _load, child: Text(l10n.retry)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 460, child: _editor(context)),
                      Expanded(child: _preview(context)),
                    ],
                  );
                }
                return ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(bottom: 18),
                  children: [
                    _editor(context, scrollable: false),
                    _preview(context, scrollable: false),
                  ],
                );
              },
            ),
    );
  }

  Widget _editor(BuildContext context, {bool scrollable = true}) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = [
      ExamGeneratorHeroHeader(
        title: l10n.examPaperDesignerTitle,
        subtitle: l10n.examPaperDesignerSubtitle,
        stats: {
          l10n.examExportFormat: localizedExportFormat(l10n, _format),
          l10n.examExportVariant: localizedExportVariant(l10n, _variant),
        },
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _designerIntro(context),
      const SizedBox(height: 12),
      _modernSection(
        context,
        icon: Icons.style_outlined,
        color: InstructorColors.primary,
        title: l10n.examPaperTemplates,
        subtitle: l10n.examPaperTemplateSetupHint,
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _templatePicker(context),
            const SizedBox(height: 12),
            _paperField(
              _templateName,
              l10n.examPaperTemplateName,
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 12),
            _layoutModePicker(context),
          ],
        ),
      ),
      _modernSection(
        context,
        icon: Icons.view_week_outlined,
        color: InstructorColors.teal,
        title: l10n.examPaperHeaderFields,
        subtitle: l10n.examPaperHeaderSetupHint,
        initiallyExpanded: true,
        child: _clusterGrid(
          context,
          children: [
            _fieldCluster(
              context,
              title: l10n.examPaperLeftColumn,
              icon: Icons.format_align_left_rounded,
              color: InstructorColors.primary,
              fields: [
                _DesignerFieldData(_left1, l10n.examPaperHeaderLeft1),
                _DesignerFieldData(_left2, l10n.examPaperHeaderLeft2),
                _DesignerFieldData(_left3, l10n.examPaperHeaderLeft3),
              ],
            ),
            _fieldCluster(
              context,
              title: l10n.examPaperCenterColumn,
              icon: Icons.format_align_center_rounded,
              color: InstructorColors.info,
              fields: [
                _DesignerFieldData(_center1, l10n.examPaperHeaderCenter1),
                _DesignerFieldData(_center2, l10n.examPaperHeaderCenter2),
              ],
            ),
            _fieldCluster(
              context,
              title: l10n.examPaperRightColumn,
              icon: Icons.format_align_right_rounded,
              color: InstructorColors.accent,
              fields: [
                _DesignerFieldData(_right1, l10n.examPaperHeaderRight1),
                _DesignerFieldData(_right2, l10n.examPaperHeaderRight2),
                _DesignerFieldData(_right3, l10n.examPaperHeaderRight3),
              ],
            ),
          ],
        ),
      ),
      _modernSection(
        context,
        icon: Icons.fact_check_outlined,
        color: InstructorColors.orange,
        title: l10n.examPaperMetadataRows,
        subtitle: l10n.examPaperMetadataSetupHint,
        child: _clusterGrid(
          context,
          children: [
            _fieldCluster(
              context,
              title: l10n.examPaperLeftColumn,
              icon: Icons.notes_outlined,
              color: InstructorColors.orange,
              fields: [
                _DesignerFieldData(_metaLeft1, l10n.examPaperMetadataLeft1),
                _DesignerFieldData(_metaLeft2, l10n.examPaperMetadataLeft2),
                _DesignerFieldData(_metaLeft3, l10n.examPaperMetadataLeft3),
              ],
            ),
            _fieldCluster(
              context,
              title: l10n.examPaperRightColumn,
              icon: Icons.translate_rounded,
              color: InstructorColors.teal,
              fields: [
                _DesignerFieldData(_metaRight1, l10n.examPaperMetadataRight1),
                _DesignerFieldData(_metaRight2, l10n.examPaperMetadataRight2),
                _DesignerFieldData(_metaRight3, l10n.examPaperMetadataRight3),
              ],
            ),
          ],
        ),
      ),
      _modernSection(
        context,
        icon: Icons.drag_indicator_rounded,
        color: InstructorColors.accent,
        title: l10n.examPaperFreeElements,
        subtitle: l10n.examPaperFreeElementsHelp,
        child: Row(
          children: [
            Expanded(
              child: _paperField(
                _freeText,
                l10n.examPaperFreeElementText,
                icon: Icons.title_rounded,
                onChanged: null,
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: l10n.examPaperAddFreeField,
              child: IconButton.filled(
                onPressed: _addFreeElement,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
      _modernSection(
        context,
        icon: Icons.low_priority_outlined,
        color: InstructorColors.info,
        title: l10n.examPaperTrailingFields,
        subtitle: l10n.examPaperFooterSetupHint,
        child: Column(
          children: [
            _fieldGrid(context, [
              _DesignerFieldData(_endLine, l10n.examPaperEndLine),
              _DesignerFieldData(_goodLuck, l10n.examPaperGoodLuckLine),
              _DesignerFieldData(_examiners, l10n.examPaperExaminersLine),
              _DesignerFieldData(_pageNumber, l10n.examPaperPageNumberFormat),
            ], icon: Icons.text_snippet_outlined),
          ],
        ),
      ),
      _modernSection(
        context,
        icon: Icons.tune_outlined,
        color: InstructorColors.cyan,
        title: l10n.exportOptions,
        subtitle: l10n.examPaperExportSetupHint,
        initiallyExpanded: true,
        child: Column(
          children: [
            _optionGrid(context, [
              _dropdownField<ExamExportVariant>(
                context,
                label: l10n.examExportVariant,
                value: _variant,
                icon: Icons.person_outline_rounded,
                items: ExamExportVariant.values,
                labelFor: (value) => localizedExportVariant(l10n, value),
                onChanged: (value) =>
                    setState(() => _variant = value ?? _variant),
              ),
              _dropdownField<ExamExportFormat>(
                context,
                label: l10n.examExportFormat,
                value: _format,
                icon: Icons.picture_as_pdf_outlined,
                items: ExamExportFormat.values,
                labelFor: (value) => localizedExportFormat(l10n, value),
                onChanged: (value) =>
                    setState(() => _format = value ?? _format),
              ),
            ]),
            const SizedBox(height: 12),
            _switchGrid(context, [
              _SwitchSpec(
                label: l10n.examStudentNameLine,
                icon: Icons.badge_outlined,
                value: _studentNameLine,
                onChanged: (value) => setState(() => _studentNameLine = value),
              ),
              _SwitchSpec(
                label: l10n.course,
                icon: Icons.school_outlined,
                value: _showCourseCode,
                onChanged: (value) => setState(() => _showCourseCode = value),
              ),
              _SwitchSpec(
                label: l10n.examInstructorName,
                icon: Icons.person_pin_outlined,
                value: _showInstructorName,
                onChanged: (value) =>
                    setState(() => _showInstructorName = value),
              ),
              _SwitchSpec(
                label: l10n.examPaperShowTotalMarks,
                icon: Icons.score_outlined,
                value: _showTotalMarks,
                onChanged: (value) => setState(() => _showTotalMarks = value),
              ),
              _SwitchSpec(
                label: l10n.examPaperShowQuestionMarks,
                icon: Icons.fact_check_outlined,
                value: _showQuestionMarks,
                onChanged: (value) =>
                    setState(() => _showQuestionMarks = value),
              ),
              _SwitchSpec(
                label: l10n.examPageBreakPerSection,
                icon: Icons.vertical_split_outlined,
                value: _pageBreakPerSection,
                onChanged: (value) =>
                    setState(() => _pageBreakPerSection = value),
              ),
            ]),
          ],
        ),
      ),
    ];
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: children,
    );
  }

  Widget _designerIntro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = [
      _StepChipData(
        icon: Icons.style_outlined,
        label: l10n.examPaperStepTemplate,
        color: InstructorColors.primary,
      ),
      _StepChipData(
        icon: Icons.edit_note_rounded,
        label: l10n.examPaperStepContent,
        color: InstructorColors.teal,
      ),
      _StepChipData(
        icon: Icons.file_download_outlined,
        label: l10n.examPaperStepExport,
        color: InstructorColors.accent,
      ),
    ];
    return _DesignerPanel(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final step in steps)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: step.color.withValues(alpha: isDark ? 0.18 : 0.09),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: step.color.withValues(alpha: isDark ? 0.36 : 0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(step.icon, size: 16, color: step.color),
                  const SizedBox(width: 6),
                  Text(
                    step.label,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _modernSection(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DesignerPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: _DesignerIcon(icon: icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          children: [child],
        ),
      ),
    );
  }

  Widget _templatePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasTemplates = _templates.any((template) => template.id != null);
    if (!hasTemplates) {
      return _SoftNotice(
        icon: Icons.info_outline_rounded,
        color: InstructorColors.info,
        text: l10n.examPaperNoSavedTemplates,
      );
    }
    return _dropdownField<int>(
      context,
      label: l10n.examPaperTemplate,
      value: _templates.any((template) => template.id == _currentTemplate?.id)
          ? _currentTemplate?.id
          : null,
      icon: Icons.layers_outlined,
      items: _templates
          .where((template) => template.id != null)
          .map((template) => template.id!)
          .toList(),
      labelFor: (id) =>
          _templates.firstWhere((template) => template.id == id).name,
      onChanged: (id) {
        final selected = _templates.firstWhere(
          (template) => template.id == id,
          orElse: () => _currentTemplate!,
        );
        setState(() {
          _currentTemplate = selected;
          _layoutMode = selected.layoutMode;
        });
        _hydrateControllers(selected);
      },
    );
  }

  Widget _layoutModePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      _LayoutOption(
        mode: ExamPaperLayoutMode.structured,
        icon: Icons.view_column_outlined,
        label: l10n.examPaperStructuredZones,
        color: InstructorColors.primary,
      ),
      _LayoutOption(
        mode: ExamPaperLayoutMode.free,
        icon: Icons.open_with_rounded,
        label: l10n.examPaperFreeDrag,
        color: InstructorColors.orange,
      ),
      _LayoutOption(
        mode: ExamPaperLayoutMode.hybrid,
        icon: Icons.dashboard_customize_outlined,
        label: l10n.examPaperHybrid,
        color: InstructorColors.accent,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final compact = constraints.maxWidth < 520;
        final itemWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              SizedBox(
                width: itemWidth,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() => _layoutMode = option.mode);
                    _refreshTemplate();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _layoutMode == option.mode
                          ? option.color.withValues(alpha: isDark ? 0.22 : 0.1)
                          : InstructorColors.surfaceColor(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _layoutMode == option.mode
                            ? option.color
                            : InstructorColors.borderColor(isDark),
                        width: _layoutMode == option.mode ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(option.icon, color: option.color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _layoutMode == option.mode
                                  ? option.color
                                  : InstructorColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (_layoutMode == option.mode)
                          Icon(
                            Icons.check_circle_rounded,
                            color: option.color,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _clusterGrid(BuildContext context, {required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }

  Widget _fieldCluster(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_DesignerFieldData> fields,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DesignerIcon(icon: icon, color: color, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _paperField(field.controller, field.label),
            ),
        ],
      ),
    );
  }

  Widget _fieldGrid(
    BuildContext context,
    List<_DesignerFieldData> fields, {
    IconData? icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: _paperField(field.controller, field.label, icon: icon),
              ),
          ],
        );
      },
    );
  }

  Widget _optionGrid(BuildContext context, List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }

  Widget _switchGrid(BuildContext context, List<_SwitchSpec> specs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 2 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final spec in specs)
              SizedBox(width: width, child: _switchTile(context, spec)),
          ],
        );
      },
    );
  }

  Widget _switchTile(BuildContext context, _SwitchSpec spec) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          _DesignerIcon(icon: spec.icon, color: InstructorColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              spec.label,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(value: spec.value, onChanged: spec.onChanged),
        ],
      ),
    );
  }

  Widget _dropdownField<T>(
    BuildContext context, {
    required String label,
    required T? value,
    required IconData icon,
    required List<T> items,
    required String Function(T value) labelFor,
    required ValueChanged<T?> onChanged,
  }) {
    return QuestionFormMenuField<T>(
      label: label,
      value: value,
      icon: icon,
      color: InstructorColors.cyan,
      valueMaxLines: 2,
      options: items
          .map(
            (item) => QuestionFormMenuOption<T>(
              value: item,
              label: labelFor(item),
              icon: icon,
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _paperField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    ValueChanged<String>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        TextField(
          controller: controller,
          decoration: _inputDecoration(
            context,
            label: label,
            icon: icon,
            showLabel: false,
          ),
          minLines: 1,
          maxLines: 2,
          onChanged: onChanged ?? (_) => _refreshTemplate(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool showLabel = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: showLabel ? label : null,
      hintText: showLabel ? null : label,
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, {bool scrollable = true}) {
    final l10n = AppLocalizations.of(context);
    final detail = _detail!;
    final template = _buildTemplate();
    final children = [
      _PanelTitle(
        icon: Icons.preview_outlined,
        color: InstructorColors.primary,
        title: l10n.examPaperLivePreview,
        subtitle: l10n.examPaperPreviewHint,
      ),
      const SizedBox(height: 10),
      _previewOptionSummary(context),
      const SizedBox(height: 12),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AspectRatio(
            aspectRatio: 210 / 297,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Times New Roman',
                      fontSize: 12,
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _paperHeader(template, detail),
                            _paperExportRows(detail),
                            const SizedBox(height: 16),
                            Expanded(child: _paperQuestions(detail)),
                            _paperTrailing(template),
                            const SizedBox(height: 18),
                            Text(
                              _resolveTokens(
                                template.footerJson['pageNumberFormat']
                                        ?.toString() ??
                                    l10n.examPaperDefaultPageNumberFormat(
                                      '{page}',
                                      '{totalPages}',
                                    ),
                                detail,
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        ..._freeElementWidgets(template, detail, size),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ];
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: _DesignerPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        _DesignerPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _paperHeader(
    ExamPaperTemplateModel template,
    ExamFullDetailModel detail,
  ) {
    final header = template.headerJson;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _zoneText(header['left'], detail, TextAlign.left)),
            Expanded(
              child: _zoneText(header['center'], detail, TextAlign.center),
            ),
            Expanded(
              child: _zoneText(header['right'], detail, TextAlign.right),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _zoneText(header['metadataLeft'], detail, TextAlign.left),
            ),
            Expanded(
              child: Text(
                detail.exam.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _zoneText(
                  header['metadataRight'],
                  detail,
                  TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 1),
      ],
    );
  }

  Widget _previewOptionSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = [
      _PreviewChipData(
        icon: Icons.person_outline_rounded,
        label: localizedExportVariant(l10n, _variant),
        color: InstructorColors.primary,
      ),
      _PreviewChipData(
        icon: Icons.picture_as_pdf_outlined,
        label: localizedExportFormat(l10n, _format),
        color: InstructorColors.orange,
      ),
      _PreviewChipData(
        icon: Icons.badge_outlined,
        label:
            '${l10n.examStudentNameLine}: ${_studentNameLine ? l10n.enabled : l10n.disabled}',
        color: _studentNameLine
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
      _PreviewChipData(
        icon: Icons.school_outlined,
        label:
            '${l10n.course}: ${_showCourseCode ? l10n.enabled : l10n.disabled}',
        color: _showCourseCode
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
      _PreviewChipData(
        icon: Icons.person_pin_outlined,
        label:
            '${l10n.examInstructorName}: ${_showInstructorName ? l10n.enabled : l10n.disabled}',
        color: _showInstructorName
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
      _PreviewChipData(
        icon: Icons.score_outlined,
        label:
            '${l10n.examPaperShowTotalMarks}: ${_showTotalMarks ? l10n.enabled : l10n.disabled}',
        color: _showTotalMarks
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
      _PreviewChipData(
        icon: Icons.fact_check_outlined,
        label:
            '${l10n.examPaperShowQuestionMarks}: ${_showQuestionMarks ? l10n.enabled : l10n.disabled}',
        color: _showQuestionMarks
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
      _PreviewChipData(
        icon: Icons.vertical_split_outlined,
        label:
            '${l10n.examPageBreakPerSection}: ${_pageBreakPerSection ? l10n.enabled : l10n.disabled}',
        color: _pageBreakPerSection
            ? InstructorColors.success
            : InstructorColors.textTertiary,
      ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in chips)
          _PreviewOptionChip(
            icon: chip.icon,
            label: chip.label,
            color: chip.color,
          ),
      ],
    );
  }

  Widget _paperExportRows(ExamFullDetailModel detail) {
    final l10n = AppLocalizations.of(context);
    final rows = <String>[
      if (_studentNameLine)
        '${l10n.examStudentNameLine}: ______________________________',
      if (_showCourseCode)
        '${l10n.course}: ${[detail.courseCode, detail.courseName].where((value) => value != null && value.trim().isNotEmpty).join(' - ')}',
      if (_showInstructorName)
        '${l10n.examInstructorName}: ______________________________',
      if (_showTotalMarks)
        '${l10n.totalMarks}: ${detail.exam.totalMarks ?? '-'}',
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(row, style: const TextStyle(fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _zoneText(dynamic raw, ExamFullDetailModel detail, TextAlign align) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        for (final item in _list(raw))
          Text(
            _resolveTokens(_valueAt([item], 0, ''), detail),
            textAlign: align,
            style: TextStyle(
              fontWeight: item is Map && item['bold'] == true
                  ? FontWeight.bold
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _paperQuestions(ExamFullDetailModel detail) {
    final items = [
      for (final section in detail.sections) ...section.items,
      ...detail.unsectionedItems,
    ];
    final previewItems = items.take(5).toList();
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < previewItems.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionFormattedText(
                  text: '${i + 1}. ${previewItems[i].questionText}',
                  fallback:
                      '${i + 1}. ${AppLocalizations.of(context).questions}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (_showQuestionMarks)
                  Text(
                    '${AppLocalizations.of(context).marks}: ${previewItems[i].marks ?? '-'}',
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _paperTrailing(ExamPaperTemplateModel template) {
    final lines = _list(template.trailingJson['lines']);
    return Column(
      children: [
        for (final line in lines)
          Text(
            _valueAt([line], 0, ''),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        const SizedBox(height: 22),
        Text(
          template.trailingJson['examiners']?.toString() ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  List<Widget> _freeElementWidgets(
    ExamPaperTemplateModel template,
    ExamFullDetailModel detail,
    Size size,
  ) {
    if (_layoutMode == ExamPaperLayoutMode.structured) return const <Widget>[];
    final elements = _list(template.headerJson['freeElements']);
    return [
      for (var i = 0; i < elements.length; i++)
        Positioned(
          left: _num((elements[i] as Map)['x']) / 210 * size.width,
          top: _num((elements[i] as Map)['y']) / 297 * size.height,
          child: GestureDetector(
            onPanUpdate: (details) => _moveFreeElement(i, details.delta, size),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                border: Border.all(color: const Color(0xFFF97316)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text(
                  _resolveTokens(_valueAt([elements[i]], 0, ''), detail),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _bottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final compact = constraints.maxWidth < 640;
        final secondaryActions = [
          _ActionSpec(
            label: l10n.examPaperSaveTemplate,
            icon: Icons.save_outlined,
            onPressed: _working || _currentTemplate?.id == null
                ? null
                : () => _saveTemplate(saveAsNew: false),
          ),
          _ActionSpec(
            label: l10n.examPaperSaveAsTemplate,
            icon: Icons.save_as_outlined,
            onPressed: _working ? null : () => _saveTemplate(saveAsNew: true),
          ),
          _ActionSpec(
            label: l10n.examPaperResetDefault,
            icon: Icons.restart_alt_rounded,
            onPressed: _working ? null : _resetDefaultTemplate,
          ),
        ];
        return Material(
          color: InstructorColors.cardColor(isDark),
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final action in secondaryActions)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: _actionPill(context, action),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _working ? null : _export,
                          icon: _working
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(l10n.examPaperExportAfterPreview),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in secondaryActions)
                        _actionPill(context, action),
                      FilledButton.icon(
                        onPressed: _working ? null : _export,
                        icon: _working
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(l10n.examPaperExportAfterPreview),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _actionPill(BuildContext context, _ActionSpec action) {
    return OutlinedButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 18),
      label: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(
          color: InstructorColors.borderColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _resolveTokens(String value, ExamFullDetailModel detail) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context);
    final replacements = <String, String>{
      'courseCode': detail.courseCode ?? '',
      'courseName': detail.courseName ?? detail.exam.title,
      'examTitle': detail.exam.title,
      'duration': detail.durationMinutes == null
          ? ''
          : '${detail.durationMinutes} ${l10n.minutes}',
      'date': now.toIso8601String().split('T').first,
      'academicYear': '${now.year}/${now.year + 1}',
      'page': '1',
      'totalPages': '8',
    };
    return value.replaceAllMapped(RegExp(r'\{([A-Za-z0-9_]+)\}'), (match) {
      return replacements[match.group(1)] ?? match.group(0)!;
    });
  }

  List<dynamic> _list(dynamic value) =>
      value is List ? value : const <dynamic>[];

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _DesignerPanel extends StatelessWidget {
  const _DesignerPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DesignerIcon(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  height: 1.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesignerIcon extends StatelessWidget {
  const _DesignerIcon({
    required this.icon,
    required this.color,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class _SoftNotice extends StatelessWidget {
  const _SoftNotice({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignerFieldData {
  const _DesignerFieldData(this.controller, this.label);

  final TextEditingController controller;
  final String label;
}

class _LayoutOption {
  const _LayoutOption({
    required this.mode,
    required this.icon,
    required this.label,
    required this.color,
  });

  final ExamPaperLayoutMode mode;
  final IconData icon;
  final String label;
  final Color color;
}

class _SwitchSpec {
  const _SwitchSpec({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _ActionSpec {
  const _ActionSpec({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
}

class _PreviewOptionChip extends StatelessWidget {
  const _PreviewOptionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChipData {
  const _PreviewChipData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class _StepChipData {
  const _StepChipData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
