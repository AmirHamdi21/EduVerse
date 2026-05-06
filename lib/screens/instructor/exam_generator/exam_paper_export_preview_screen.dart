import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/exams/exam_export_options_model.dart';
import '../../../models/exams/exam_full_detail_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_paper_template_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';

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
    _templateName.text = template.name;
    final header = template.headerJson;
    final trailing = template.trailingJson;
    _setZone([_left1, _left2, _left3], header['left']);
    _setZone([_center1, _center2], header['center']);
    _setZone([_right1, _right2, _right3], header['right']);
    _setZone([_metaLeft1, _metaLeft2, _metaLeft3], header['metadataLeft']);
    _setZone([_metaRight1, _metaRight2, _metaRight3], header['metadataRight']);
    final lines = _list(trailing['lines']);
    _endLine.text = _valueAt(lines, 0, 'End of questions');
    _goodLuck.text = _valueAt(lines, 1, 'Good Luck');
    _examiners.text =
        trailing['examiners']?.toString() ??
        'Examiners: ______________________________';
    _pageNumber.text =
        template.footerJson['pageNumberFormat']?.toString() ??
        'Page {page} of {totalPages}';
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
    return base.copyWith(
      name: _templateName.text.trim().isEmpty
          ? 'Exam paper template'
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
    final canShowActions = !_loading && _error == null && _detail != null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examPaperDesignerTitle)),
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
                      SizedBox(width: 420, child: _editor(context)),
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
    final children = [
      ExamGeneratorHeroHeader(
        title: l10n.examPaperDesignerTitle,
        subtitle: l10n.examPaperDesignerSubtitle,
        stats: {
          l10n.examExportFormat: _format == ExamExportFormat.pdf
              ? l10n.examExportPdfDocument
              : l10n.examExportWordDocument,
          l10n.examExportVariant: localizedExportVariant(l10n, _variant),
        },
      ),
      const SizedBox(height: 12),
      _section(
        title: l10n.examPaperTemplates,
        initiallyExpanded: true,
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue:
                  _templates.any(
                    (template) => template.id == _currentTemplate?.id,
                  )
                  ? _currentTemplate?.id
                  : null,
              decoration: InputDecoration(labelText: l10n.examPaperTemplate),
              items: _templates
                  .where((template) => template.id != null)
                  .map(
                    (template) => DropdownMenuItem<int>(
                      value: template.id,
                      child: Text(template.name),
                    ),
                  )
                  .toList(),
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
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _templateName,
              decoration: InputDecoration(
                labelText: l10n.examPaperTemplateName,
              ),
              onChanged: (_) => _refreshTemplate(),
            ),
            const SizedBox(height: 10),
            SegmentedButton<ExamPaperLayoutMode>(
              segments: [
                ButtonSegment(
                  value: ExamPaperLayoutMode.structured,
                  label: Text(l10n.examPaperStructuredZones),
                ),
                ButtonSegment(
                  value: ExamPaperLayoutMode.free,
                  label: Text(l10n.examPaperFreeDrag),
                ),
                ButtonSegment(
                  value: ExamPaperLayoutMode.hybrid,
                  label: Text(l10n.examPaperHybrid),
                ),
              ],
              selected: {_layoutMode},
              onSelectionChanged: (value) {
                setState(() => _layoutMode = value.first);
                _refreshTemplate();
              },
            ),
          ],
        ),
      ),
      _section(
        title: l10n.examPaperHeaderFields,
        initiallyExpanded: true,
        child: Column(
          children: [
            _field(_left1, l10n.examPaperHeaderLeft1),
            _field(_left2, l10n.examPaperHeaderLeft2),
            _field(_left3, l10n.examPaperHeaderLeft3),
            _field(_center1, l10n.examPaperHeaderCenter1),
            _field(_center2, l10n.examPaperHeaderCenter2),
            _field(_right1, l10n.examPaperHeaderRight1),
            _field(_right2, l10n.examPaperHeaderRight2),
            _field(_right3, l10n.examPaperHeaderRight3),
          ],
        ),
      ),
      _section(
        title: l10n.examPaperMetadataRows,
        child: Column(
          children: [
            _field(_metaLeft1, l10n.examPaperMetadataLeft1),
            _field(_metaLeft2, l10n.examPaperMetadataLeft2),
            _field(_metaLeft3, l10n.examPaperMetadataLeft3),
            _field(_metaRight1, l10n.examPaperMetadataRight1),
            _field(_metaRight2, l10n.examPaperMetadataRight2),
            _field(_metaRight3, l10n.examPaperMetadataRight3),
          ],
        ),
      ),
      _section(
        title: l10n.examPaperFreeElements,
        child: Column(
          children: [
            Text(l10n.examPaperFreeElementsHelp),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _freeText,
                    decoration: InputDecoration(
                      labelText: l10n.examPaperFreeElementText,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _addFreeElement,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
      _section(
        title: l10n.examPaperTrailingFields,
        child: Column(
          children: [
            _field(_endLine, l10n.examPaperEndLine),
            _field(_goodLuck, l10n.examPaperGoodLuckLine),
            _field(_examiners, l10n.examPaperExaminersLine),
            _field(_pageNumber, l10n.examPaperPageNumberFormat),
          ],
        ),
      ),
      _section(
        title: l10n.exportOptions,
        child: Column(
          children: [
            DropdownButtonFormField<ExamExportVariant>(
              initialValue: _variant,
              decoration: InputDecoration(labelText: l10n.examExportVariant),
              items: ExamExportVariant.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(localizedExportVariant(l10n, value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _variant = value ?? _variant),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ExamExportFormat>(
              initialValue: _format,
              decoration: InputDecoration(labelText: l10n.examExportFormat),
              items: ExamExportFormat.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(localizedExportFormat(l10n, value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _format = value ?? _format),
            ),
            SwitchListTile(
              value: _studentNameLine,
              onChanged: (value) => setState(() => _studentNameLine = value),
              title: Text(l10n.examStudentNameLine),
            ),
            SwitchListTile(
              value: _showCourseCode,
              onChanged: (value) => setState(() => _showCourseCode = value),
              title: Text(l10n.course),
            ),
            SwitchListTile(
              value: _showInstructorName,
              onChanged: (value) => setState(() => _showInstructorName = value),
              title: Text(l10n.examInstructorName),
            ),
            SwitchListTile(
              value: _pageBreakPerSection,
              onChanged: (value) =>
                  setState(() => _pageBreakPerSection = value),
              title: Text(l10n.examPageBreakPerSection),
            ),
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

  Widget _section({
    required String title,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [child],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        onChanged: (_) => _refreshTemplate(),
      ),
    );
  }

  Widget _preview(BuildContext context, {bool scrollable = true}) {
    final l10n = AppLocalizations.of(context);
    final detail = _detail!;
    final template = _buildTemplate();
    final children = [
      Text(
        l10n.examPaperLivePreview,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
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
                            const SizedBox(height: 16),
                            Expanded(child: _paperQuestions(detail)),
                            _paperTrailing(template),
                            const SizedBox(height: 18),
                            Text(
                              _resolveTokens(
                                template.footerJson['pageNumberFormat']
                                        ?.toString() ??
                                    'Page {page} of {totalPages}',
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
            child: Text(
              '${i + 1}. ${previewItems[i].questionText.isEmpty ? 'Question snapshot' : previewItems[i].questionText}',
              style: const TextStyle(fontSize: 12),
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
        final compact = constraints.maxWidth < 640;
        return Material(
          color: Theme.of(context).cardColor,
          elevation: 10,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _compactAction(
                            tooltip: l10n.examPaperSaveTemplate,
                            icon: Icons.save_outlined,
                            onPressed: _working || _currentTemplate?.id == null
                                ? null
                                : () => _saveTemplate(saveAsNew: false),
                          ),
                          _compactAction(
                            tooltip: l10n.examPaperSaveAsTemplate,
                            icon: Icons.save_as_outlined,
                            onPressed: _working
                                ? null
                                : () => _saveTemplate(saveAsNew: true),
                          ),
                          _compactAction(
                            tooltip: l10n.examPaperResetDefault,
                            icon: Icons.restart_alt_rounded,
                            onPressed: _working ? null : _resetDefaultTemplate,
                          ),
                          _compactAction(
                            tooltip: l10n.examPaperApplyToExam,
                            icon: Icons.check_circle_outline,
                            onPressed: _working ? null : _applyTemplate,
                          ),
                        ],
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
                      OutlinedButton.icon(
                        onPressed: _working || _currentTemplate?.id == null
                            ? null
                            : () => _saveTemplate(saveAsNew: false),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.examPaperSaveTemplate),
                      ),
                      OutlinedButton.icon(
                        onPressed: _working
                            ? null
                            : () => _saveTemplate(saveAsNew: true),
                        icon: const Icon(Icons.save_as_outlined),
                        label: Text(l10n.examPaperSaveAsTemplate),
                      ),
                      OutlinedButton.icon(
                        onPressed: _working ? null : _resetDefaultTemplate,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(l10n.examPaperResetDefault),
                      ),
                      OutlinedButton.icon(
                        onPressed: _working ? null : _applyTemplate,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l10n.examPaperApplyToExam),
                      ),
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

  Widget _compactAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(onPressed: onPressed, icon: Icon(icon)),
    );
  }

  String _resolveTokens(String value, ExamFullDetailModel detail) {
    final now = DateTime.now();
    final replacements = <String, String>{
      'courseCode': detail.courseCode ?? '',
      'courseName': detail.courseName ?? detail.exam.title,
      'examTitle': detail.exam.title,
      'duration': detail.durationMinutes == null
          ? ''
          : '${detail.durationMinutes} minutes',
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
